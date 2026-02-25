class_name EventManager extends RefCounted

var propertydata_ins = PropertyData.new()
var achievement_ins = Achievement.new()
var judgement_ins = Judgement.new()
var talent_ins = TalentParser.new()
var weight_ins = WeightParser.new()
var condition_parser_ins = ConditionParser.new()
var agelist:Dictionary = {}
var eventlist:Dictionary = {}

func _init() -> void:
	var fa = FileAccess.open("res://data/age.json", FileAccess.READ)
	agelist = JSON.parse_string(fa.get_as_text())
	fa.close()
	fa = FileAccess.open("res://data/events.json", FileAccess.READ)
	eventlist = JSON.parse_string(fa.get_as_text())
	fa.close()
	

func random_talent() -> Array:
	var all_talent_ids = []
	for id in talent_ins._talents:
		var talent = talent_ins._talents[id]
		# 跳过独占天赋
		if talent.has("exclusive") and talent["exclusive"] == 1:
			continue
		all_talent_ids.append(int(id))
	
	all_talent_ids.shuffle()
	var count = min(15, all_talent_ids.size())
	return all_talent_ids.slice(0, count)

func apply_talent(talents: Array):
	propertydata_ins.status[PropertyData.Types.TLT] = talents

func check_event(event_id: int, ignore_no_random: bool = false) -> bool:
	var event = eventlist[str(event_id)]
	# 检查NoRandom
	if not ignore_no_random and event.has("NoRandom") and event["NoRandom"] == 1:
		return false
	# 检查exclude
	if event.has("exclude"):
		if condition_parser_ins.conditional_judgement(event["exclude"], 
			propertydata_ins.status[PropertyData.Types.EVT], 
			propertydata_ins.status):
			return false
	# 检查include
	if event.has("include"):
		return condition_parser_ins.conditional_judgement(event["include"],
			propertydata_ins.status[PropertyData.Types.EVT],
			propertydata_ins.status)
	return true

func random_event(year: int) -> int:
	var availble_events = []
	var processed_events = WeightParser.process(agelist[str(year)]["event"])
	for item in processed_events:
		var parsed_events = WeightParser.parse_event(item)
		availble_events.append(parsed_events)
	var filtered_events = []
	for item in availble_events:
		if check_event(int(item["id"])):
			filtered_events.append(item)
	availble_events = filtered_events
	for item in propertydata_ins.status[PropertyData.Types.TLT]:
		var to_remove = talent_ins.check_exclude(item)
		if to_remove != null and to_remove != []:
			for i in to_remove:
				for rem in availble_events:
					if rem["id"] == i:
						availble_events.erase(rem)
	
	var final_event = WeightParser.random_select_from_parsed(availble_events)
	if final_event != "":
		return int(final_event)
	return -1

func is_dead() -> bool:
	return propertydata_ins.status[PropertyData.Types.LIF] < 1

func gainACHV(opportunity: Achievement.GainAchivementOpportunity) -> Array:
	var achvs = achievement_ins.checkACHV(opportunity, propertydata_ins.status, propertydata_ins.status[PropertyData.Types.EVT])
	if achvs != []:
		var achv: Array = propertydata_ins.status[PropertyData.Types.ACHV]
		achv.append(achvs)
		propertydata_ins.status[PropertyData.Types.ACHV] = achv
	return achvs

func next_year() -> int:
	propertydata_ins.status[PropertyData.Types.AGE] += 1
	return propertydata_ins.status[PropertyData.Types.AGE]

func start_game(talents: Array) -> void:
	# 重置属性
	propertydata_ins.RESET()
	# 应用天赋
	apply_talent(talents)
	
	# 计算初始状态
	var init_data = talent_ins.get_init_status(talents)
	propertydata_ins.status.merge(init_data)
	# 检查START成就
	gainACHV(Achievement.GainAchivementOpportunity.START)

func execute_event(event_id: int) -> Dictionary:
	var event = eventlist[str(event_id)]
	var result = {
		"description": event.get("event", ""),
		"postEvent": event.get("postEvent", null),
		"grade": event.get("grade", 0)
	}
	# 处理分支
	if event.has("branch"):
		for branch in event["branch"]:
			var parts = branch.split(":")
			var condition = parts[0]
			var next_id = int(parts[1])
			if condition_parser_ins.conditional_judgement(condition,
				propertydata_ins.status[PropertyData.Types.EVT],
				propertydata_ins.status):
				# 应用当前事件效果
				if event.has("effect"):
					propertydata_ins.apply_effects(event["effect"])
				# 记录事件
				propertydata_ins.add_event(event_id)
				# 递归执行分支
				result["branch"] = execute_event(next_id)
				return result
	# 没有分支或都不满足
	if event.has("effect"):
		propertydata_ins.apply_effects(event["effect"])
	propertydata_ins.add_event(event_id)
	return result

func execute_next(from: int = -1) -> Dictionary:
	var next_event
	var triggered_talent = []
	
	var talent_effects = talent_ins.check_conditional_talents(
		propertydata_ins.status[PropertyData.Types.EVT],
		propertydata_ins.status
	)
	if talent_effects.size() > 0:
		propertydata_ins.apply_effects(talent_effects)
		triggered_talent.append(talent_effects)
	if from != -1 and eventlist[str(from)].has("branch"):
		var task_id = condition_parser_ins.parse_branch(eventlist[str(from)]["branch"], propertydata_ins.status[PropertyData.Types.EVT], propertydata_ins.status)
		if task_id != "":
			next_event = task_id
	else:
		next_event = str(random_event(propertydata_ins.status[PropertyData.Types.AGE]))
	var des = execute_event(next_event)
	var gained_achivements = gainACHV(Achievement.GainAchivementOpportunity.TRAJECTORY)
	return {
	"event": int(next_event),
	"description": des,
	"triggered_talents": triggered_talent,
	"gained_achivements": gained_achivements,
	"dead": is_dead()
	}
