class_name TalentParser extends RefCounted

var _talents: Dictionary = {}
var _player_talents: Array = []
var condition_talents: Array = []  # 存储条件天赋的数据

func _init() -> void:
	var talents = FileAccess.open("res://data/talents.json", FileAccess.READ)
	_talents = JSON.parse_string(talents.get_as_text())

func RESET():
	_player_talents = []
	condition_talents = []

func get_talent_info(id: int) -> Dictionary:
	var talent = _talents[str(id)]
	var talent_id = talent["id"]
	var talent_name = talent["name"]
	var talent_grade = talent["grade"]
	var talent_effect = talent["effect"] if talent.has("effect") else null
	var talent_status = talent["status"] if talent.has("status") else null
	var talent_condition = talent["condition"] if talent.has("condition") else null
	var talent_max_triggers = talent["max_triggers"] if talent.has("max_triggers") else null
	var talent_exclude = talent["exclude"] if talent.has("exclude") else null
	var talent_exclusive = talent.has("exclusive") and talent["exclusive"] == 1
	var replacement = talent["replacement"] if talent.has("replacement") else null
	
	# 处理id
	var talent_id_parsed = str(talent_id) if typeof(talent_id) == TYPE_INT else talent_id
	
	# 处理exclude（统一转成int）
	var talent_exclude_parsed = null
	if talent_exclude != null:
		talent_exclude_parsed = []
		if typeof(talent_exclude) == TYPE_ARRAY:
			for item in talent_exclude:
				if typeof(item) == TYPE_STRING:
					talent_exclude_parsed.append(int(item))
				else:
					talent_exclude_parsed.append(item)
	
	# 处理replacement（保持原样，不处理talent列表）
	var replacement_parsed = null
	if replacement != null:
		replacement_parsed = replacement.duplicate(true)
		# 注意：这里不处理 replacement["talent"]，保留原始格式
		# 因为在 apply_replacement 中会根据类型分别处理
	
	return {
		"id": talent_id_parsed,
		"name": talent_name,
		"grade": talent_grade,
		"effect": talent_effect,
		"status": talent_status,
		"condition": talent_condition,
		"max_triggers": talent_max_triggers,
		"exclude": talent_exclude_parsed,
		"exclusive": talent_exclusive,
		"replacement": replacement_parsed
	}

func check_exclude(talent_id: int) -> Array:
	var talent_info = get_talent_info(talent_id)
	var excluded_list = []
	if talent_info["exclude"] != null:
		for item in talent_info["exclude"]:
			excluded_list.append(str(item))
	return excluded_list

func apply_replacement(talent_id: int, depth: int = 0) -> int:
	# 防止无限递归（最多10层）
	if depth > 10:
		push_error("天赋替换递归过深: ", talent_id)
		return talent_id
	
	var talent_info = get_talent_info(talent_id)
	var replace_list = talent_info["replacement"]
	
	# 没有替换规则，返回原天赋
	if replace_list == null:
		return talent_id
	
	var new_id = talent_id
	
	# 处理 grade 类型替换
	if replace_list.has("grade"):
		var target_grade = replace_list["grade"][0]  # 取出目标稀有度
		new_id = _get_random_talent_by_grade(target_grade, talent_info["exclude"])
	
	# 处理 talent 类型替换
	elif replace_list.has("talent"):
		var weight_data = replace_list["talent"]
		new_id = int(WeightParser.random_select(weight_data))
	
	# 如果替换后的天赋不同，且也有replacement，则继续递归
	if new_id != talent_id:
		var new_talent_info = get_talent_info(new_id)
		if new_talent_info["replacement"] != null:
			return apply_replacement(new_id, depth + 1)
	
	return new_id

# 按稀有度随机获取一个天赋
func _get_random_talent_by_grade(target_grade: int, exclude_list: Array) -> int:
	var candidates = []
	
	for id_str in _talents:
		var talent = _talents[id_str]
		var talent_id = int(id_str)
		
		# 跳过独占天赋
		if talent.has("exclusive") and talent["exclusive"] == 1:
			continue
		
		# 检查稀有度
		if int(talent["grade"]) != target_grade:
			continue
		
		# 检查互斥
		if exclude_list != null and talent_id in exclude_list:
			continue
		
		candidates.append(talent_id)
	
	if candidates.is_empty():
		push_error("没有找到稀有度 ", target_grade, " 的天赋")
		return -1
	
	return candidates[randi() % candidates.size()]
	
func get_init_status(talents: Array) -> Dictionary:
	_player_talents = talents
	var effects: Dictionary = {
		"SPR": 0, "MNY": 0, "CHR": 0, "STR": 0, "INT": 0,
		"LIF": 0, "AGE": 0,
	}
	var conditional_list = []  # 临时存储
	var init_status = 0
	
	for item in _player_talents:
		var talent_info = get_talent_info(item)
		
		# 处理status（初始属性点）
		if talent_info.has("status") and talent_info["status"] != null:
			init_status += int(talent_info["status"])
		
		# 处理effect（直接属性加成）
		if talent_info.has("effect") and talent_info["effect"] != null:
			var effect = talent_info["effect"]
			for prop in ["SPR", "MNY", "CHR", "STR", "INT", "LIF", "AGE"]:
				if effect.has(prop):
					effects[prop] = effects.get(prop, 0) + int(effect[prop])
			
			# 处理随机属性
			if effect.has("RDM"):
				var rdm_value = int(effect["RDM"])
				var random_prop = ["SPR", "MNY", "CHR", "STR", "INT"].pick_random()
				effects[random_prop] += rdm_value
		
		# 处理条件触发天赋
		if talent_info.has("condition") and talent_info["condition"] != null:
			conditional_list.append({
				"id": item,
				"condition": talent_info["condition"],
				"effect": talent_info["effect"],
			})
	
	condition_talents = conditional_list  # 保存到类变量
	
	return {
		PropertyData.Types.CHR: effects["CHR"],
		PropertyData.Types.STR: effects["STR"],
		PropertyData.Types.INT: effects["INT"],
		PropertyData.Types.SPR: effects["SPR"],
		PropertyData.Types.MNY: effects["MNY"],
		PropertyData.Types.LIF: effects["LIF"],
		PropertyData.Types.AGE: effects["AGE"],
		"status": init_status,
		"conditional_talents": conditional_list
	}

# 每年调用，检查条件天赋
func check_conditional_talents(experienced_events: Array, current_status: Dictionary) -> Dictionary:
	var status: Dictionary = {
		"SPR": 0, "MNY": 0, "CHR": 0, "STR": 0, "INT": 0,
		"LIF": 0, "AGE": 0
	}
	
	var cp = ConditionParser.new()
	
	for talent_data in condition_talents:
		
		var condition = talent_data["condition"]
		if cp.parse_branch(condition, experienced_events, current_status):
			
			var effect = talent_data["effect"]
			if effect != null:
				for prop in ["SPR", "MNY", "CHR", "STR", "INT", "LIF", "AGE"]:
					if effect.has(prop):
						status[prop] = status.get(prop, 0) + int(effect[prop])
				
				if effect.has("RDM"):
					var rdm_value = int(effect["RDM"])
					var random_prop = ["SPR", "MNY", "CHR", "STR", "INT"].pick_random()
					status[random_prop] += rdm_value
	
	return status