extends Control

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	# 初始化时更新一次UI大小
	call_deferred("_update_ui_scale")

func _on_viewport_size_changed() -> void:
	_update_ui_scale()

func _update_ui_scale() -> void:
	var viewport_size = get_viewport_rect().size
	var viewport_height = viewport_size.y
	var viewport_width = viewport_size.x
	
	# 计算字体大小
	var title_font_size = max(28, int(viewport_height * 0.055))
	var subtitle_font_size = max(14, int(viewport_height * 0.025))
	var button_font_size = max(16, int(viewport_height * 0.028))
	
	# 更新标题字体
	var title_label_settings = LabelSettings.new()
	title_label_settings.font = $Titles/Title.label_settings.font
	title_label_settings.font_size = title_font_size
	$Titles/Title.label_settings = title_label_settings
	
	# 更新副标题字体
	var subtitle_label_settings = LabelSettings.new()
	subtitle_label_settings.font = $Titles/Subtitle.label_settings.font
	subtitle_label_settings.font_size = subtitle_font_size
	$Titles/Subtitle.label_settings = subtitle_label_settings
	
	# 计算按钮尺寸
	var button_height = max(40, int(viewport_height * 0.065))
	var button_width = max(200, int(viewport_width * 0.25))
	
	# 更新按钮容器的大小和间距
	var button_spacing = max(8, int(viewport_height * 0.015))
	$Buttons.add_theme_constant_override("separation", button_spacing)
	
	# 计算按钮容器的总高度
	var total_button_height = button_height * 3 + button_spacing * 2
	$Buttons.offset_left = -button_width / 2.0
	$Buttons.offset_right = button_width / 2.0
	$Buttons.offset_top = -total_button_height / 2.0
	$Buttons.offset_bottom = total_button_height / 2.0
	
	# 更新每个按钮的大小和字体
	for button in $Buttons.get_children():
		if button is Button:
			button.custom_minimum_size = Vector2(button_width, button_height)
			button.begin_bulk_theme_override()
			button.add_theme_font_size_override("font_size", button_font_size)
			button.end_bulk_theme_override()
			# 更新 pivot_offset
			if button.has_method("_init_pivot"):
				button._init_pivot()
	
	# 更新标题容器的大小
	var title_height = title_font_size + subtitle_font_size + 10
	$Titles.offset_left = -button_width / 2.0
	$Titles.offset_right = button_width / 2.0
	$Titles.offset_top = -title_height / 2.0
	$Titles.offset_bottom = title_height / 2.0
