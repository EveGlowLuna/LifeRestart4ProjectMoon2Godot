extends Button

@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var pressed_scale: Vector2 = Vector2(0.9, 0.9)

var _current_tween: Tween

func _ready() -> void:
	mouse_entered.connect(_button_enter)
	mouse_exited.connect(_button_exit)
	button_down.connect(_button_down)  # 改为 button_down
	button_up.connect(_button_up)      # 添加 button_up
	
	await get_tree().process_frame
	_init_pivot()

func _init_pivot() -> void:
	pivot_offset = size / 2.0

func _button_enter() -> void:
	_kill_current_tween()
	_current_tween = create_tween()
	_current_tween.tween_property(self, "scale", hover_scale, 0.1).set_trans(Tween.TRANS_SINE)

func _button_exit() -> void:
	_kill_current_tween()
	_current_tween = create_tween()
	_current_tween.tween_property(self, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE)

func _button_down() -> void:  # 按下瞬间触发
	_kill_current_tween()
	_current_tween = create_tween()
	_current_tween.tween_property(self, "scale", pressed_scale, 0.06).set_trans(Tween.TRANS_SINE)

func _button_up() -> void:  # 松开时触发
	_kill_current_tween()
	_current_tween = create_tween()
	
	# 检查鼠标是否还在按钮上
	if is_mouse_over():
		_current_tween.tween_property(self, "scale", hover_scale, 0.12).set_trans(Tween.TRANS_SINE)
	else:
		_current_tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)

# 辅助函数：检查鼠标是否在按钮上
func is_mouse_over() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())

# 辅助函数：中断当前动画
func _kill_current_tween() -> void:
	if _current_tween and _current_tween.is_running():
		_current_tween.kill()
