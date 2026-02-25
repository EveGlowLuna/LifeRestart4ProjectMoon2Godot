class_name Achievement extends RefCounted

var _achievements:Dictionary = {}
var _havedachievements:Array = []
var data_util_instance = DataUtil.new()

enum GainAchivementOpportunity {
	START, # 游戏开始
	TRAJECTORY, # 游戏进行中
	SUMMARY, # 总结环节
	END # 点击总结界面的重开
}

func _init():
	load_achievement()

func load_achievement():
	var file = FileAccess.open("res://data/achievement.json", FileAccess.READ)
	if not file:
		return
	var achivements = file.get_as_text()
	_achievements = JSON.parse_string(achivements)
	file.close()
	data_util_instance.init_data()
	data_util_instance.load_data()
	var json = JSON.new()
	json.parse(data_util_instance.data["ACHV"])
	_havedachievements = json.data

func save_achievement():
	data_util_instance.data["ACHV"] = JSON.stringify(_havedachievements)
	

func checkACHV_trajectory(id: int, experienced_events: Array, current_status: Dictionary):
	if _achievements.has(str(id)):
		if _achievements[str(id)]["opportunity"] == "START" or _achievements[str(id)]["opportunity"] == "SUMMARY" or _achievements[str(id)]["opportunity"] == "END":
			return false
		var cpinstance = ConditionParser.new()
		var res = cpinstance.conditional_judgement(_achievements[str(id)]["condition"], experienced_events, current_status)
		return res

func checkACHV_start(id: int, current_status: Dictionary):
	if _achievements.has(str(id)):
		if _achievements[str(id)]["opportunity"] == "START" or _achievements[str(id)]["opportunity"] == "SUMMARY"or _achievements[str(id)]["opportunity"] == "END":
			return false
		var cpinstance = ConditionParser.new()
		var res = cpinstance.conditional_judgement(_achievements[str(id)]["condition"], [], current_status)
		return res

func checkACHV_SUMMARY(id: int, experienced_events: Array, current_status: Dictionary):
	if _achievements.has(str(id)):
		if _achievements[str(id)]["opportunity"] == "START" or _achievements[str(id)]["opportunity"] == "SUMMARY" or _achievements[str(id)]["opportunity"] == "END":
			return false
		var cpinstance = ConditionParser.new()
		var res = cpinstance.conditional_judgement(_achievements[str(id)]["condition"], experienced_events, current_status)
		return res

func checkACHV_end(id: int, current_status: Dictionary):
	if _achievements.has(str(id)):
		if _achievements[str(id)]["opportunity"] == "START" or _achievements[str(id)]["opportunity"] == "SUMMARY" or _achievements[str(id)]["opportunity"] == "TRAJECTORY":
			return false
		var cpinstance = ConditionParser.new()
		var res = cpinstance.conditional_judgement(_achievements[str(id)]["condition"], [], current_status)
		return res

func checkACHV(chance: GainAchivementOpportunity, current_status: Dictionary, experienced_events: Array = []):
	var gained = []
	match chance:
		GainAchivementOpportunity.START:
			for i in _achievements:
				var value = _achievements[i]
				if value["opportunity"] == "START":
					if checkACHV_start(value["id"],current_status):
						gained.append(value["id"])
		GainAchivementOpportunity.TRAJECTORY:
			for i in _achievements:
				var value = _achievements[i]
				if value["opportunity"] == "TRAJECTORY":
					if checkACHV_trajectory(value["id"], experienced_events, current_status):
						gained.append(value["id"])
		GainAchivementOpportunity.SUMMARY:
			for i in _achievements:
				var value = _achievements[i]
				if value["opportunity"] == "SUMMARY":
					if checkACHV_SUMMARY(value["id"], experienced_events, current_status):
						gained.append(value["id"])
		GainAchivementOpportunity.END:
			for i in _achievements:
				var value = _achievements[i]
				if value["opportunity"] == "END":
					if checkACHV_end(value["id"], current_status):
						gained.append(value["id"])
				
	return gained