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
	
	# 处理exclude
	var talent_exclude_parsed = []
	if talent_exclude != null:
		talent_exclude_parsed = []
		if typeof(talent_exclude) == TYPE_ARRAY:
			for item in talent_exclude:
				talent_exclude_parsed.append(int(item) if typeof(item) == TYPE_STRING else item)
	
	# 处理replacement
	var replacement_parsed = null
	if replacement != null:
		replacement_parsed = replacement
		if replacement_parsed.has("talent"):
			replacement_parsed["talent"] = WeightParser.process(replacement["talent"])
	
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

func apply_replacement(talent_id) -> int:
	var talent_info = get_talent_info(talent_id)
	var replace_list = talent_info["replacement"]
	if replace_list == null:
		return talent_id
	return int(WeightParser.random_select(replace_list))
	
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
				"triggered": false  # 可选：标记是否已触发
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
		# 可选：如果已经触发过且不想重复触发
		# if talent_data["triggered"]:
		#     continue
		
		var condition = talent_data["condition"]
		if cp.parse_branch(condition, experienced_events, current_status):
			# 标记已触发
			# talent_data["triggered"] = true
			
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