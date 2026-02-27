extends Node

var propertydata_ins = PropertyData.new()
var achievement_ins = Achievement.new()
var judgement_ins = Judgement.new()
var talent_ins = TalentParser.new()
var weight_ins = WeightParser.new()
var condition_parser_ins = ConditionParser.new()
var status_point = 20
var agelist:Dictionary = {}
var eventlist:Dictionary = {}
var temp

func _init() -> void:
	var fa = FileAccess.open("res://data/age.json", FileAccess.READ)
	agelist = JSON.parse_string(fa.get_as_text())
	fa.close()
	fa = FileAccess.open("res://data/events.json", FileAccess.READ)
	eventlist = JSON.parse_string(fa.get_as_text())
	fa.close()
	

func random_talent() -> Array:
	# 获取加成所需的数据
	var addition_values = {
		"TMS": propertydata_ins.status.get(PropertyData.Types.TMS, 0),
		"CACHV": propertydata_ins.status.get(PropertyData.Types.CACHV, 0)
	}
	
	# 获取保留天赋ID
	var reserved_id = -1
	var ext_value = propertydata_ins.status.get(PropertyData.Types.EXT, null)
	print("random_talent - EXT值: ", ext_value)
	if ext_value != null and ext_value != 0:
		reserved_id = int(ext_value)
		print("random_talent - 保留天赋ID: ", reserved_id)
	
	# 调用带概率的版本
	return talent_ins.random_talent(null, addition_values, reserved_id)

func apply_talent(talents: Array):
	propertydata_ins.status[PropertyData.Types.TLT] = talents
	var replaced_talents = []
	for i in talents:
		if talent_ins._talents[str(i)].has("replacement"):
			var replaced = talent_ins.apply_replacement(int(i))
			propertydata_ins.status[PropertyData.Types.TLT].erase(i)
			propertydata_ins.status[PropertyData.Types.TLT].append(replaced)
			replaced_talents.append({
			"origin_talent": talent_ins._talents[str(i)]["id"],
			"replaced_talent": replaced
			})
	return replaced_talents

func start_game(selected_talent: Array):
	var replaced_talents = apply_talent(selected_talent)
	
	
	for item in propertydata_ins.status[PropertyData.Types.TLT]:
		if talent_ins._talents[str(item)].has("effect") and !talent_ins._talents[str(item)].has("condition"):
			propertydata_ins.apply_effects(talent_ins._talents[str(item)]["effect"])
	
	var gained_achv = gainACHV(Achievement.GainAchivementOpportunity.START)
	# 不用返回修改了的数值因为数值在游戏内实时显示
	return {
	"replaced_talents": replaced_talents,
	"gained_achievement": gained_achv
	}
	

func check_event(event_id: int, ignore_no_random: bool = false) -> bool:
	var event = eventlist[str(event_id)]
	if event_id == 50630:
		print("检查 50630:")
		print("  EVT列表: ", propertydata_ins.status[PropertyData.Types.EVT])
		print("  exclude条件: ", event.get("exclude", "无"))
		if event.has("exclude"):
			var result = condition_parser_ins.conditional_judgement(
				event["exclude"], 
				propertydata_ins.status[PropertyData.Types.EVT], 
				propertydata_ins.status
			)
			print("  exclude判断结果: ", result)
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

func summary_game():
	# 先计算总评
	propertydata_ins.status[PropertyData.Types.SUM] = propertydata_ins.calculate_sum()
	
	return {
	"gained_achievement": gainACHV(Achievement.GainAchivementOpportunity.SUMMARY),
	"judgement": {
	PropertyData.Types.HCHR: judgement_ins.judge(Judgement.JudgementType.HCHR, propertydata_ins.status[PropertyData.Types.HCHR]),
	PropertyData.Types.HINT: judgement_ins.judge(Judgement.JudgementType.HINT, propertydata_ins.status[PropertyData.Types.HINT]),
	PropertyData.Types.HSTR: judgement_ins.judge(Judgement.JudgementType.HSTR, propertydata_ins.status[PropertyData.Types.HSTR]),
	PropertyData.Types.HMNY: judgement_ins.judge(Judgement.JudgementType.HMNY, propertydata_ins.status[PropertyData.Types.HMNY]),
	PropertyData.Types.HSPR: judgement_ins.judge(Judgement.JudgementType.HSPR, propertydata_ins.status[PropertyData.Types.HSPR]),
	PropertyData.Types.HAGE: judgement_ins.judge(Judgement.JudgementType.HAGE, propertydata_ins.status[PropertyData.Types.HAGE]),
	PropertyData.Types.SUM: judgement_ins.judge(Judgement.JudgementType.SUM, propertydata_ins.status[PropertyData.Types.SUM]),
	}
	}

func end_game(ext_id: int = -1):
	# 重开次数+1
	propertydata_ins.status[PropertyData.Types.TMS] += 1
	# 检查END成就
	gainACHV(Achievement.GainAchivementOpportunity.END)
	# 设置保留天赋
	print("end_game - 收到的ext_id: ", ext_id)
	if ext_id != -1:
		propertydata_ins.status[PropertyData.Types.EXT] = ext_id
		print("end_game - 设置EXT为: ", ext_id)
	else:
		# 如果没有选择保留天赋，清空EXT
		propertydata_ins.status[PropertyData.Types.EXT] = null
		print("end_game - 清空EXT")
	# 保存数据
	propertydata_ins.save_value()
	# 重置加载
	propertydata_ins.RESET()

func random_event(year: int) -> int:
	var availble_events = []
	var processed_events = weight_ins.process(agelist[str(year)]["event"])
	for item in processed_events:
		var parsed_events = weight_ins.parse_event(item)
		availble_events.append(parsed_events)
	var filtered_events = []
	for item in availble_events:
		if check_event(int(item["id"])):
			filtered_events.append(item)
	availble_events = filtered_events
	var final_event = weight_ins.random_select_from_parsed(availble_events)
	if final_event != "":
		return int(final_event)
	if availble_events.is_empty():
		print("警告: 年龄 ", year, " 没有可用事件")
		return 10069
	elif filtered_events.is_empty():
		print("警告：年龄 ", year, " 中所有事件均被过滤")
		return 10069
	return -1

func is_dead() -> bool:
	return propertydata_ins.status[PropertyData.Types.LIF] < 1

func gainACHV(opportunity: Achievement.GainAchivementOpportunity) -> Array:
	var achvs = achievement_ins.checkACHV(opportunity, propertydata_ins.status, propertydata_ins.status[PropertyData.Types.EVT], propertydata_ins.status[PropertyData.Types.ACHV])
	if achvs != []:
		for achv_id in achvs:
			propertydata_ins.add_achievement(achv_id)
	return achvs

func next_year() -> int:
	propertydata_ins.status[PropertyData.Types.AGE] += 1
	return propertydata_ins.status[PropertyData.Types.AGE]


func execute_event(event_id: int) -> Dictionary:
	var event = eventlist[str(event_id)]
	var result = {
		"description": event.get("event", ""),
		"postEvent": event.get("postEvent", null),
		"grade": event.get("grade", 0),
		"final_event_id": event_id  # 记录最终执行的事件ID
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
				var branch_result = execute_event(next_id)
				result["branch"] = branch_result
				result["final_event_id"] = branch_result["final_event_id"]  # 使用branch的最终ID
				return result
	# 没有分支或都不满足
	if event.has("effect"):
		propertydata_ins.apply_effects(event["effect"])
	propertydata_ins.add_event(event_id)
	return result

func execute_next(from: int = -1) -> Dictionary:
	var next_event
	var triggered_talent = []
	
	# 触发条件天赋
	var talent_effects = talent_ins.check_conditional_talents(
		propertydata_ins.status[PropertyData.Types.EVT],
		propertydata_ins.status
	)
	if talent_effects.size() > 0:
		propertydata_ins.apply_effects(talent_effects)
		triggered_talent.append(talent_effects)
	
	# 确定要执行的事件
	if from != -1 and eventlist[str(from)].has("branch"):
		var task_id = condition_parser_ins.parse_branch(
			eventlist[str(from)]["branch"], 
			propertydata_ins.status[PropertyData.Types.EVT], 
			propertydata_ins.status
		)
		if task_id != "":
			next_event = int(task_id)
		else:
			# 如果没有满足的分支，随机选一个
			next_event = random_event(propertydata_ins.status[PropertyData.Types.AGE])
	else:
		next_event = random_event(propertydata_ins.status[PropertyData.Types.AGE])
	
	# 检查是否真的选到了事件
	if next_event == -1 or next_event == null:
		push_error("没有可用事件！年龄: ", propertydata_ins.status[PropertyData.Types.AGE])
		next_event = "10069"
	
	var des = execute_event(next_event)
	var gained_achivements = gainACHV(Achievement.GainAchivementOpportunity.TRAJECTORY)
	
	return {
		"event": next_event,
		"final_event": des.get("final_event_id", next_event),  # 返回最终执行的事件ID
		"description": des,
		"triggered_talents": triggered_talent,
		"gained_achivements": gained_achivements,
		"dead": is_dead()
	}
