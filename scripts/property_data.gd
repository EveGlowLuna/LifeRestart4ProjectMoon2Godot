extends RefCounted
class_name PropertyData

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
	TMS,    # 次数
	
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
	"SPR": Types.STR,
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
