extends CanvasLayer
class_name ShaderTransition

signal transition_started
signal transition_completed

@export var mask_width: float = 300.0
@export var skew_factor: float = 0.3
@export var transition_duration: float = 1.0
@export var auto_cleanup: bool = true

var color_rect: ColorRect
var shader_material: ShaderMaterial
var is_transitioning: bool = false
var new_scene_path: String
var _new_scene_image: Image
var _new_scene_texture: ImageTexture
var _temp_viewport: SubViewport

func _ready():
	# 设置为最高层级，确保在所有内容之上
	layer = 100
	
	# 获取ColorRect节点
	color_rect = $ColorRect
	if not color_rect:
		push_error("找不到ColorRect节点")
		return
	
	# 获取ShaderMaterial
	if color_rect.material is ShaderMaterial:
		shader_material = color_rect.material
	else:
		push_error("ColorRect的材质不是ShaderMaterial")
		return
	
	# 初始隐藏
	color_rect.hide()

func start_transition(target_scene_path: String):
	if is_transitioning:
		return
	
	print("====== 开始转场 ======")
	print("目标场景: ", target_scene_path)
	
	is_transitioning = true
	new_scene_path = target_scene_path
	
	# 预加载新场景并创建预览
	await setup_new_scene_preview()

	# 设置shader参数
	setup_shader_parameters()

	# 显示遮罩（使用hint_screen_texture会自动捕获屏幕内容）
	color_rect.show()

	# 开始并等待动画完成
	await animate_transition()
	
	# 动画完成后切换场景
	finish_transition()

func setup_new_scene_preview():
	# 创建临时视口来渲染新场景
	_temp_viewport = SubViewport.new()
	_temp_viewport.size = get_viewport().size
	_temp_viewport.transparent_bg = false
	_temp_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	# 加载新场景
	var new_scene_packed = load(new_scene_path)
	if not new_scene_packed:
		push_error("无法加载场景: " + new_scene_path)
		return
	
	var new_scene_instance = new_scene_packed.instantiate()
	_temp_viewport.add_child(new_scene_instance)
	
	# 将视口添加到树中（但不可见）
	add_child(_temp_viewport)
	
	# 等待渲染完成
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 获取新场景纹理并转换为Image（创建副本）
	var viewport_texture = _temp_viewport.get_texture()
	_new_scene_image = viewport_texture.get_image()
	
	# 创建ImageTexture
	_new_scene_texture = ImageTexture.create_from_image(_new_scene_image)
	
	if shader_material:
		shader_material.set_shader_parameter("new_scene", _new_scene_texture)
		print("new_scene纹理已设置")

func setup_shader_parameters():
	if not shader_material:
		push_error("shader_material为空")
		return
	
	var viewport = get_viewport()
	shader_material.set_shader_parameter("mask_width", mask_width)
	shader_material.set_shader_parameter("skew_factor", skew_factor)
	shader_material.set_shader_parameter("progress", 0.0)
	shader_material.set_shader_parameter("screen_size", viewport.size)
	print("shader参数: mask_width=", mask_width, " skew_factor=", skew_factor)


func animate_transition() -> void:
	print("开始动画")
	transition_started.emit()

	var start_time = Time.get_ticks_msec() / 1000.0
	var duration = max(0.001, transition_duration)

	while true:
		var now = Time.get_ticks_msec() / 1000.0
		var t = (now - start_time) / duration
		if t >= 1.0:
			set_progress(1.0)
			break
		else:
			set_progress(t)
			await get_tree().process_frame

	print("动画完成")

func set_progress(value: float):
	if shader_material:
		shader_material.set_shader_parameter("progress", value)
		# 注释掉进度输出
		# if int(value * 10) > int((value - 0.1) * 10):
		# 	print("动画进度: ", int(value * 100), "%")

func finish_transition():
	print("完成转场，准备切换场景")
	
	# 清理临时视口
	if _temp_viewport:
		_temp_viewport.queue_free()
		_temp_viewport = null
	
	# 切换到新场景
	get_tree().change_scene_to_file(new_scene_path)
	
	transition_completed.emit()
	
	if auto_cleanup:
		queue_free()
