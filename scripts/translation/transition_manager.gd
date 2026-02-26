extends Node
# 移除 class_name TransitionManager 这行

# 注意：不要使用静态变量，因为自动加载已经是单例了
@export var default_transition_scene: PackedScene = preload("res://scenes/ShaderTransition.tscn")

var is_transitioning: bool = false

func _ready():
	# 不需要 instance = self，因为自动加载已经提供了全局访问
	pass

func transition_to(scene_path: String, custom_params: Dictionary = {}) -> ShaderTransition:
	# 防止重复触发
	if is_transitioning:
		push_warning("转场正在进行中，忽略新的转场请求")
		return null
	
	var tree = get_tree()
	if not tree or not tree.current_scene:
		push_error("场景树未准备好")
		return null
	
	is_transitioning = true
	
	# 创建转场实例
	var transition_instance = default_transition_scene.instantiate()
	
	# 确保是ShaderTransition类型
	if not (transition_instance is ShaderTransition):
		push_error("转场场景类型错误 - 需要继承自ShaderTransition")
		transition_instance.queue_free()
		is_transitioning = false
		return null
	
	var transition = transition_instance as ShaderTransition
	# 将转场节点挂到场景树根节点，保证在切换场景时仍然可见
	tree.root.add_child(transition)
	
	# 设置自定义参数
	if custom_params.has("mask_width"):
		transition.mask_width = custom_params["mask_width"]
	if custom_params.has("skew_factor"):
		transition.skew_factor = custom_params["skew_factor"]
	if custom_params.has("duration"):
		transition.transition_duration = custom_params["duration"]
	
	# 监听转场完成信号，重置锁
	transition.transition_completed.connect(func(): is_transitioning = false)
	
	# 开始转场
	transition.start_transition(scene_path)
	
	return transition

# 便捷方法
func to(scene_path: String) -> void:
	transition_to(scene_path)
