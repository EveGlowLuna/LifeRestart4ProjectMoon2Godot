class_name PropertyData extends RefCounted

enum Types {
	# 本局属性
	AGE,    # 年龄
	CHR,    # 运气
	INT,    # 智力
	STR,    # 体质
	MNY,    # 家境
	SPR,    # 精神力
	LIF,    # 生命
	TLT,    # 天赋
	EVT,    # 事件
	
	TMS,    # 重开次数
	
	# 自动计算的极值
	LAGE,   # 最低年龄
	HAGE,   # 最高年龄
	LCHR,   # 最低运气
	HCHR,   # 最高运气
	LINT,   # 最低智力
	HINT,   # 最高智力
	LSTR,   # 最低体质
	HSTR,   # 最高体质
	LMNY,   # 最低家境
	HMNY,   # 最高家境
	LSPR,   # 最低精神力
	HSPR,   # 最高精神力
	
	SUM,    # 总评
	
	EXT,    # 继承天赋
	
	# 总计/成就相关
	ATLT,   # 拥有过的天赋
	AEVT,   # 触发过的事件
	ACHV,   # 达成的成就
	
	CTLT,   # 天赋选择数
	CEVT,   # 事件收集数
	CACHV,  # 成就达成数
	
	# 总数
	TTLT,   # 总天赋数
	TEVT,   # 总事件数
	TACHV,  # 总成就数
	
	# 比率
	REVT,   # 事件收集率
	RTLT,   # 天赋选择率
	RACHV,  # 成就达成率
	
	# 特殊
	RDM     # 随机属性
}

# 特殊类型映射
const SPECIAL := {
	Types.RDM: [
		Types.CHR,
		Types.INT,
		Types.STR,
		Types.MNY,
		Types.SPR
	]
}

static var _string_enum_types = {
	"AGE": Types.AGE,
	"CHR": Types.CHR,
	"INT": Types.INT,
	"STR": Types.STR,
	"MNY": Types.MNY,
	"SPR": Types.SPR,
	"LIF": Types.LIF,
	"TLT": Types.TLT,
	"EVT": Types.EVT,
	"TMS": Types.TMS,
	
	"LAGE": Types.LAGE,
	"HAGE": Types.HAGE,
	"HCHR": Types.HCHR,
	"LINT": Types.LINT,
	"LSTR": Types.LSTR,
	"HSTR": Types.HSTR,
	"LMNY": Types.LMNY,
	"HMNY": Types.HMNY,
	"LSPR": Types.LSPR,
	"HSPR": Types.HSPR,
	
	"SUM": Types.SUM,
	
	"EXT": Types.EXT,
	
	"ATLT": Types.ATLT,
	"AEVT": Types.AEVT,
	"ACHV": Types.ACHV,
	
	"CTLT": Types.CTLT,
	"CEVT": Types.CEVT,
	"CACHV": Types.CACHV,
	
	"TTLT": Types.TTLT,
	"TEVT": Types.TEVT,
	"TACHV": Types.TACHV,
	
	"REVT": Types.REVT,
	"RTLT": Types.RTLT,
	"RACHV": Types.RACHV,
	
	"RDM": Types.RDM
}

var origin_status: Dictionary = {
	Types.AGE: 0, Types.CHR: 0, Types.INT: 0, Types.STR: 0,
	Types.MNY: 0, Types.SPR: 0, Types.LIF: 1,  # LIF默认1
	Types.TLT: [], Types.EVT: [], Types.TMS: 0,
	
	Types.LAGE: 999999, Types.HAGE: -999999,  # 极值初始化为极端值
	Types.LCHR: 999999, Types.HCHR: -999999,
	Types.LINT: 999999, Types.HINT: -999999,
	Types.LSTR: 999999, Types.HSTR: -999999,
	Types.LMNY: 999999, Types.HMNY: -999999,
	Types.LSPR: 999999, Types.HSPR: -999999,
	
	Types.SUM: 0, Types.EXT: null,
	
	Types.ATLT: [], Types.AEVT: [], Types.ACHV: [],
	Types.CTLT: 0, Types.CEVT: 0, Types.CACHV: 0,
	Types.TTLT: 0, Types.TEVT: 0, Types.TACHV: 0,
	Types.REVT: 0.0, Types.RTLT: 0.0, Types.RACHV: 0.0,
	
	Types.RDM: 0,
}

var status:Dictionary = origin_status.duplicate(true)
var experienced_events: Array = []
var excluded_events: Array = []
var datautil = DataUtil.new()

func RESET():
	status = origin_status.duplicate(true)
	status[Types.TLT] = []
	status[Types.EVT] = []
	status[Types.ATLT] = []
	status[Types.AEVT] = []
	status[Types.ACHV] = []

func load_value():
	datautil.init_data()
	datautil.load_data()
	for item in datautil.data:
		if _string_enum_types.has(item):
			match item:
				"AEVT", "ATLT", "ACHV":
					# 单独的字符串数据解析
					var json = JSON.new()
					json.parse(datautil.data[item])
					var res = json.data
					status[_string_enum_types[item]] = res
				"times":
					# 带字符串的数字解析+针对变量
					status[Types.TMS] = int(datautil.data[item])
				"extendTalent":
					pass # 属性不需要保留的天赋
				_:
					# 通用数字解析
					status[_string_enum_types[item]] = datautil.data[item]
	# 总评是局内的评价，不修改
	# 总数
	status[Types.CTLT] = len(status[Types.ATLT])
	status[Types.CEVT] = len(status[Types.AEVT])
	status[Types.CACHV] = len(status[Types.ACHV])
	# 事件、成就、天赋总数
	var eventfile = FileAccess.open("res://data/events.json",FileAccess.READ)
	var events = JSON.parse_string(eventfile.get_as_text())
	eventfile.close()
	status[Types.TEVT] = len(events)
	var talentfile = FileAccess.open("res://data/talents.json",FileAccess.READ)
	var talents = JSON.parse_string(talentfile.get_as_text())
	talentfile.close()
	status[Types.TTLT] = len(talents)
	var achievementfile = FileAccess.open("res://data/achievement.json",FileAccess.READ)
	var achievements = JSON.parse_string(achievementfile.get_as_text())
	achievementfile.close()
	status[Types.TACHV] = len(achievements)
	
	# 比率
	status[Types.REVT] = float(status[Types.CEVT]) / float(status[Types.TEVT]) if status[Types.TEVT] > 0 else 0.0
	status[Types.RTLT] = float(status[Types.CTLT]) / float(status[Types.TTLT]) if status[Types.TTLT] > 0 else 0.0
	status[Types.RACHV] = float(status[Types.CACHV]) / float(status[Types.ACHV]) if status[Types.TACHV] > 0 else 0.0
	
	
	

func add_value(key:String, add_int:int):
	status[_string_enum_types[key]] += add_int
	if status[Types.RDM] > 0:
		# 随机分配给五个属性：
		var res:Dictionary = {
			Types.CHR: 0,
			Types.INT: 0,
			Types.STR: 0,
			Types.MNY: 0,
			Types.SPR: 0
		}
		for i in range(status[Types.RDM]):
			var prop = SPECIAL[Types.RDM].pick_random()
			res[prop] += 1
		status[Types.RDM] = 0
	update_extremes_from_status()

# 在 PropertyData.gd 中添加这个方法
func update_extremes_from_status() -> void:
	# 更新年龄极值
	status[Types.LAGE] = min(status[Types.LAGE], status[Types.AGE])
	status[Types.HAGE] = max(status[Types.HAGE], status[Types.AGE])
	# 更新运气极值
	status[Types.LCHR] = min(status[Types.LCHR], status[Types.CHR])
	status[Types.HCHR] = max(status[Types.HCHR], status[Types.CHR])
	# 更新智力极值
	status[Types.LINT] = min(status[Types.LINT], status[Types.INT])
	status[Types.HINT] = max(status[Types.HINT], status[Types.INT])
	# 更新体质极值
	status[Types.LSTR] = min(status[Types.LSTR], status[Types.STR])
	status[Types.HSTR] = max(status[Types.HSTR], status[Types.STR])
	# 更新家境极值
	status[Types.LMNY] = min(status[Types.LMNY], status[Types.MNY])
	status[Types.HMNY] = max(status[Types.HMNY], status[Types.MNY])
	# 更新精神力极值
	status[Types.LSPR] = min(status[Types.LSPR], status[Types.SPR])
	status[Types.HSPR] = max(status[Types.HSPR], status[Types.SPR])
	# 更新获得过的计数
	status[Types.CTLT] = len(status[Types.ATLT])
	status[Types.CEVT] = len(status[Types.AEVT])
	status[Types.CACHV] = len(status[Types.ACHV])
	# 更新比率
	status[Types.RTLT] = float(status[Types.CTLT]) / float(status[Types.TTLT]) if status[Types.TTLT] > 0 else 0.0
	status[Types.REVT] = float(status[Types.CEVT]) / float(status[Types.TEVT]) if status[Types.TEVT] > 0 else 0.0
	status[Types.RACHV] = float(status[Types.CACHV]) / float(status[Types.TACHV]) if status[Types.TACHV] > 0 else 0.0

func save_value(extendTalent: int = 0):
	for item in datautil.data:
		if _string_enum_types.has(item):
			match item:
				"AEVT", "ATLT", "ACHV":
					# 单独的字符串数据解析
					var res = JSON.stringify(status[_string_enum_types[item]])
					datautil.data[item] = res
				"times":
					# 带字符串的数字解析+针对变量
					datautil.data[item] = str(status[Types.TMS])
				"extendTalent":
					datautil.data[item] = str(extendTalent)
				_:
					# 通用数字解析
					datautil.data[item] = status[_string_enum_types[item]]
	datautil.update_data()

func apply_effects(effects: Dictionary):
	for item in effects:
		if status.has(_string_enum_types[item]) and status[_string_enum_types[item]] != null:
			add_value(item, effects[item])

func check_dead():
	return status.get(Types.LIF, 1) < 1

func age_next() -> int:
	add_value("AGE", 1)
	return status[Types.AGE]

func add_event(event_id: int) -> void:
	if event_id not in status[Types.EVT]:
		status[Types.EVT].append(event_id)
	if event_id not in status[Types.AEVT]:
		status[Types.AEVT].append(event_id)
	status[Types.CEVT] = status[Types.AEVT].size()

func add_talent(talent_id: int) -> void:
	if talent_id not in status[Types.ATLT]:
		status[Types.ATLT].append(talent_id)
	status[Types.CTLT] = status[Types.ATLT].size()

func add_achievement(ach_id: int) -> void:
	if ach_id not in status[Types.ACHV]:
		status[Types.ACHV].append(ach_id)
	status[Types.CACHV] = status[Types.ACHV].size()

func set_extend_talent(talent_id: int) -> void:
	status[Types.EXT] = talent_id

func calculate_sum() -> int:
	return floor((status[Types.HCHR] + status[Types.HINT] + status[Types.HSTR] + status[Types.HMNY] + status[Types.HSPR]) * 2 + status[Types.HAGE] / 2)

func judge_life() -> Dictionary:
	var judgement = Judgement.new()
	return {
		Types.HCHR: judgement.judge(Judgement.JudgementType.HCHR, status[Types.HCHR]),
		Types.HINT: judgement.judge(Judgement.JudgementType.HINT, status[Types.HINT]),
		Types.HSTR: judgement.judge(Judgement.JudgementType.HSTR, status[Types.HSTR]),
		Types.HMNY: judgement.judge(Judgement.JudgementType.HMNY, status[Types.HMNY]),
		Types.HSPR: judgement.judge(Judgement.JudgementType.HSPR, status[Types.HSPR]),
		Types.HAGE: judgement.judge(Judgement.JudgementType.HAGE, status[Types.HAGE])
	}