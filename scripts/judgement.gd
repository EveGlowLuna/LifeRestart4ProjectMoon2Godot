class_name Judgement extends Node

enum JudgementLevel {
	judge, # 评价
	level, # 等级
}

enum JudgementType{
	HCHR, HINT, HSTR, HMNY, HSPR, HAGE, SUM, TMS, CACHV
}

var HCHR_judgement: Dictionary = {
	0: {
	JudgementLevel.judge: "地狱",
	JudgementLevel.level: 0
	},
	1: {
	JudgementLevel.judge: "折磨",
	JudgementLevel.level: 0
	},
	2: {
	JudgementLevel.judge: "不佳",
	JudgementLevel.level: 0
	},
	4: {
	JudgementLevel.judge: "普通",
	JudgementLevel.level: 0
	},
	7: {
	JudgementLevel.judge: "优秀",
	JudgementLevel.level: 1
	},
	9: {
	JudgementLevel.judge: "罕见",
	JudgementLevel.level: 2
	},
	11: {
	JudgementLevel.judge: "逆天",
	JudgementLevel.level: 3
	}
}

var HINT_judgement: Dictionary = {
	0: {
	JudgementLevel.judge: "地狱",
	JudgementLevel.level: 0
	},
	1: {
	JudgementLevel.judge: "折磨",
	JudgementLevel.level: 0
	},
	2: {
	JudgementLevel.judge: "不佳",
	JudgementLevel.level: 0
	},
	4: {
	JudgementLevel.judge: "普通",
	JudgementLevel.level: 0
	},
	7: {
	JudgementLevel.judge: "优秀",
	JudgementLevel.level: 1
	},
	9: {
	JudgementLevel.judge: "罕见",
	JudgementLevel.level: 2
	},
	11: {
	JudgementLevel.judge: "逆天",
	JudgementLevel.level: 3
	},
	21: {
	JudgementLevel.judge: "你怎么这么强？",
	JudgementLevel.level: 3
	},
	131: {
	JudgementLevel.judge: "你怎么这么强？",
	JudgementLevel.level: 3
	},
	501: {
	JudgementLevel.judge: "！？强强？！",
	JudgementLevel.level: 3
	}
}

var HSTR_judgement: Dictionary = {
	0: {
	JudgementLevel.judge: "地狱",
	JudgementLevel.level: 0
	},
	1: {
	JudgementLevel.judge: "折磨",
	JudgementLevel.level: 0
	},
	2: {
	JudgementLevel.judge: "不佳",
	JudgementLevel.level: 0
	},
	4: {
	JudgementLevel.judge: "普通",
	JudgementLevel.level: 0
	},
	7: {
	JudgementLevel.judge: "优秀",
	JudgementLevel.level: 1
	},
	9: {
	JudgementLevel.judge: "罕见",
	JudgementLevel.level: 2
	},
	11: {
	JudgementLevel.judge: "逆天",
	JudgementLevel.level: 3
	},
	21: {
	JudgementLevel.judge: "你怎么这么强？",
	JudgementLevel.level: 3
	},
	101: {
	JudgementLevel.judge: "你怎么这么强？",
	JudgementLevel.level: 3
	},
	401: {
	JudgementLevel.judge: "！？强强？！",
	JudgementLevel.level: 3
	},
	1001: {
	JudgementLevel.judge: "！？强强？！",
	JudgementLevel.level: 3
	},
	2001: {
	JudgementLevel.judge: "！？强强？！",
	JudgementLevel.level: 3
	}
}

var HMNY_judgement: Dictionary = { 
	0: { 
		JudgementLevel.judge: "地狱", 
		JudgementLevel.level: 0 
	}, 
	1: { 
		JudgementLevel.judge: "折磨", 
		JudgementLevel.level: 0 
	}, 
	2: { 
		JudgementLevel.judge: "不佳", 
		JudgementLevel.level: 0 
	}, 
	4: { 
		JudgementLevel.judge: "普通", 
		JudgementLevel.level: 0 
	}, 
	7: { 
		JudgementLevel.judge: "优秀", 
		JudgementLevel.level: 1 
	}, 
	9: { 
		JudgementLevel.judge: "罕见", 
		JudgementLevel.level: 2 
	}, 
	11: { 
		JudgementLevel.judge: "逆天", 
		JudgementLevel.level: 3 
	} 
}

var HSPR_judgement: Dictionary = { 
	0: { 
		JudgementLevel.judge: "扭曲", 
		JudgementLevel.level: 0 
	}, 
	1: { 
		JudgementLevel.judge: "折磨", 
		JudgementLevel.level: 0 
	}, 
	2: { 
		JudgementLevel.judge: "不幸", 
		JudgementLevel.level: 0 
	}, 
	4: { 
		JudgementLevel.judge: "普通", 
		JudgementLevel.level: 0 
	}, 
	7: { 
		JudgementLevel.judge: "幸福", 
		JudgementLevel.level: 1 
	}, 
	9: { 
		JudgementLevel.judge: "神备", 
		JudgementLevel.level: 2 
	}, 
	11: { 
		JudgementLevel.judge: "天命", 
		JudgementLevel.level: 3 
	} 
}

var HAGE_judgement: Dictionary = { 
	0: { 
		JudgementLevel.judge: "胎死腹中", 
		JudgementLevel.level: 0 
	}, 
	1: { 
		JudgementLevel.judge: "早夭", 
		JudgementLevel.level: 0 
	}, 
	10: { 
		JudgementLevel.judge: "少年", 
		JudgementLevel.level: 0 
	}, 
	18: { 
		JudgementLevel.judge: "而立", 
		JudgementLevel.level: 0 
	}, 
	40: { 
		JudgementLevel.judge: "不惑", 
		JudgementLevel.level: 0 
	}, 
	60: { 
		JudgementLevel.judge: "花甲", 
		JudgementLevel.level: 1 
	}, 
	70: { 
		JudgementLevel.judge: "古稀", 
		JudgementLevel.level: 1 
	}, 
	80: { 
		JudgementLevel.judge: "杖朝", 
		JudgementLevel.level: 2 
	}, 
	90: { 
		JudgementLevel.judge: "南山", 
		JudgementLevel.level: 2 
	}, 
	95: { 
		JudgementLevel.judge: "血魔", 
		JudgementLevel.level: 3 
	}, 
	100: { 
		JudgementLevel.judge: "血魔", 
		JudgementLevel.level: 3 
	}, 
	500: { 
		JudgementLevel.judge: "鸿园的仙人", 
		JudgementLevel.level: 3 
	} 
}

var SUM_judgement: Dictionary = { 
	0: { 
		JudgementLevel.judge: "拉完了", 
		JudgementLevel.level: 0 
	}, 
	41: { 
		JudgementLevel.judge: "NPC", 
		JudgementLevel.level: 0 
	}, 
	50: { 
		JudgementLevel.judge: "NPC", 
		JudgementLevel.level: 0 
	}, 
	60: { 
		JudgementLevel.judge: "普通", 
		JudgementLevel.level: 0 
	}, 
	80: { 
		JudgementLevel.judge: "人上人", 
		JudgementLevel.level: 1 
	}, 
	100: { 
		JudgementLevel.judge: "顶级", 
		JudgementLevel.level: 2 
	}, 
	110: { 
		JudgementLevel.judge: "顶级", 
		JudgementLevel.level: 3 
	}, 
	120: { 
		JudgementLevel.judge: "夯", 
		JudgementLevel.level: 3 
	} 
}

# 重开次数评价（影响紫色天赋概率）
var TMS_judgement: Dictionary = {
	0: {
		JudgementLevel.judge: "抽到紫色概率不变",
		JudgementLevel.level: 0
	},
	10: {
		JudgementLevel.judge: "抽到紫色概率翻倍",
		JudgementLevel.level: 1
	},
	30: {
		JudgementLevel.judge: "抽到紫色概率三倍",
		JudgementLevel.level: 1
	},
	50: {
		JudgementLevel.judge: "抽到紫色概率四倍",
		JudgementLevel.level: 2
	},
	70: {
		JudgementLevel.judge: "抽到紫色概率五倍",
		JudgementLevel.level: 2
	},
	100: {
		JudgementLevel.judge: "抽到紫色概率六倍",
		JudgementLevel.level: 3
	}
}

# 成就数量评价（影响橙色天赋概率）
var CACHV_judgement: Dictionary = {
	0: {
		JudgementLevel.judge: "抽到橙色概率不变",
		JudgementLevel.level: 0
	},
	10: {
		JudgementLevel.judge: "抽到橙色概率翻倍",
		JudgementLevel.level: 1
	},
	30: {
		JudgementLevel.judge: "抽到橙色概率三倍",
		JudgementLevel.level: 1
	},
	50: {
		JudgementLevel.judge: "抽到橙色概率四倍",
		JudgementLevel.level: 2
	},
	70: {
		JudgementLevel.judge: "抽到橙色概率五倍",
		JudgementLevel.level: 2
	},
	100: {
		JudgementLevel.judge: "抽到橙色概率六倍",
		JudgementLevel.level: 3
	}
}

func judge(type: JudgementType, value: int) -> Dictionary:
	match type:
		JudgementType.HCHR:
			var keys = HCHR_judgement.keys()
			keys.sort()
			for key in keys:
				if value <= key:
					return HCHR_judgement[key]
			return HCHR_judgement[keys.back()]
		JudgementType.HINT:
			var keys = HINT_judgement.keys()
			keys.sort()
			for key in keys:
				if value <= key:
					return HINT_judgement[key]
			return HINT_judgement[keys.back()]
		JudgementType.HSTR:
			var keys = HSTR_judgement.keys()
			keys.sort()
			for key in keys:
				if value <= key:
					return HSTR_judgement[key]
			return HSTR_judgement[keys.back()]
		JudgementType.HMNY:
			var keys = HMNY_judgement.keys()
			keys.sort()
			for key in keys:
				if value <= key:
					return HMNY_judgement[key]
			return HMNY_judgement[keys.back()]
		JudgementType.HSPR:
			var keys = HSPR_judgement.keys()
			keys.sort()
			for key in keys:
				if value <= key:
					return HSPR_judgement[key]
			return HSPR_judgement[keys.back()]
		JudgementType.HAGE:
			var keys = HAGE_judgement.keys()
			keys.sort()
			for key in keys:
				if value <= key:
					return HAGE_judgement[key]
			return HAGE_judgement[keys.back()]
		JudgementType.SUM:
			var keys = SUM_judgement.keys()
			keys.sort()
			for key in keys:
				if value <= key:
					return SUM_judgement[key]
			return SUM_judgement[keys.back()]
		JudgementType.TMS:
			var keys = TMS_judgement.keys()
			keys.sort()
			for key in keys:
				if value >= key:
					continue
				return TMS_judgement[keys[max(0, keys.find(key) - 1)]]
			return TMS_judgement[keys.back()]
		JudgementType.CACHV:
			var keys = CACHV_judgement.keys()
			keys.sort()
			for key in keys:
				if value >= key:
					continue
				return CACHV_judgement[keys[max(0, keys.find(key) - 1)]]
			return CACHV_judgement[keys.back()]
	return {}