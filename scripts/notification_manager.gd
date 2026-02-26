extends CanvasLayer

# 通知管理器 - 用于显示右上角的通知消息

const NOTIFICATION_SCENE = preload("res://scenes/Notification.tscn")

# 配置参数
const NOTIFICATION_SPACING = 10  # 通知之间的间距
const NOTIFICATION_MARGIN_TOP = 20  # 距离顶部的边距
const NOTIFICATION_MARGIN_RIGHT = 20  # 距离右侧的边距
const NOTIFICATION_DURATION = 3.0  # 通知显示时长（秒）
const SLIDE_IN_DURATION = 0.3  # 滑入动画时长
const SLIDE_OUT_DURATION = 0.3  # 滑出动画时长

# 当前活动的通知列表
var active_notifications: Array = []

func _ready() -> void:
	# 设置为不可点击
	layer = 100  # 确保在最上层
	follow_viewport_enabled = true

# 显示通知
# message: 通知内容
# duration: 显示时长（可选，默认使用 NOTIFICATION_DURATION）
func show_notification(message: String, duration: float = NOTIFICATION_DURATION) -> void:
	var notification = NOTIFICATION_SCENE.instantiate()
	notification.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 设置通知内容
	var label = notification.get_node("MarginContainer/Label")
	label.text = message
	
	# 添加到场景
	add_child(notification)
	
	# 计算初始位置（屏幕外右侧）
	var viewport_size = get_viewport().get_visible_rect().size
	var notification_size = notification.custom_minimum_size
	var start_x = viewport_size.x  # 屏幕外
	var target_x = viewport_size.x - notification_size.x - NOTIFICATION_MARGIN_RIGHT
	
	# 计算Y位置（考虑已有通知）
	var target_y = _calculate_notification_y_position()
	
	# 设置初始位置
	notification.position = Vector2(start_x, target_y)
	
	# 创建通知数据
	var notification_data = {
		"node": notification,
		"target_y": target_y,
		"duration": duration,
		"state": "sliding_in"  # sliding_in, showing, sliding_out, moving_up
	}
	active_notifications.append(notification_data)
	
	# 滑入动画
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(notification, "position:x", target_x, SLIDE_IN_DURATION)
	tween.finished.connect(func(): _on_slide_in_finished(notification_data))

# 计算新通知的Y位置
func _calculate_notification_y_position() -> float:
	var y_pos = NOTIFICATION_MARGIN_TOP
	
	# 遍历现有通知，计算累积高度
	for notif_data in active_notifications:
		var notif = notif_data["node"]
		if is_instance_valid(notif):
			y_pos += notif.custom_minimum_size.y + NOTIFICATION_SPACING
	
	return y_pos

# 滑入动画完成
func _on_slide_in_finished(notification_data: Dictionary) -> void:
	if not is_instance_valid(notification_data["node"]):
		return
	
	notification_data["state"] = "showing"
	
	# 等待指定时长后滑出
	await get_tree().create_timer(notification_data["duration"]).timeout
	
	if is_instance_valid(notification_data["node"]) and notification_data in active_notifications:
		_slide_out_notification(notification_data)

# 滑出通知
func _slide_out_notification(notification_data: Dictionary) -> void:
	if not is_instance_valid(notification_data["node"]):
		_remove_notification(notification_data)
		return
	
	notification_data["state"] = "sliding_out"
	var notification = notification_data["node"]
	var viewport_size = get_viewport().get_visible_rect().size
	
	# 滑出动画
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(notification, "position:x", viewport_size.x, SLIDE_OUT_DURATION)
	tween.finished.connect(func(): _on_slide_out_finished(notification_data))

# 滑出动画完成
func _on_slide_out_finished(notification_data: Dictionary) -> void:
	_remove_notification(notification_data)
	_update_notification_positions()

# 移除通知
func _remove_notification(notification_data: Dictionary) -> void:
	if notification_data in active_notifications:
		active_notifications.erase(notification_data)
	
	if is_instance_valid(notification_data["node"]):
		notification_data["node"].queue_free()

# 更新所有通知的位置（当有通知被移除时）
func _update_notification_positions() -> void:
	var y_pos = NOTIFICATION_MARGIN_TOP
	
	for notif_data in active_notifications:
		var notif = notif_data["node"]
		if not is_instance_valid(notif):
			continue
		
		var new_target_y = y_pos
		
		# 如果位置需要改变，创建移动动画
		if abs(notif.position.y - new_target_y) > 1.0:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(notif, "position:y", new_target_y, 0.3)
		
		notif_data["target_y"] = new_target_y
		y_pos += notif.custom_minimum_size.y + NOTIFICATION_SPACING

# 清除所有通知
func clear_all_notifications() -> void:
	for notif_data in active_notifications.duplicate():
		_remove_notification(notif_data)
	active_notifications.clear()
