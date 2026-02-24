extends RefCounted
class_name ConditionParser

func parse_branch(branch: Array, experienced_events: Array, current_status: Dictionary) -> Variant:

	for item in branch:
		var parts = item.split(":")
		var condition = parts[0].replace(" ", "")
		var task_id = parts[1].replace(" ", "")
		
		var is_satisfied = conditional_judgement(condition, experienced_events, current_status)
		if is_satisfied:
			return task_id  # 返回第一个满足的，不继续检查后面的
	
	return null  # 没有满足的条件


# 条件判断主函数
func conditional_judgement(condition: String, experienced_events: Array, current_status: Dictionary) -> bool:
	# 1. 去除首尾空格
	var cond = condition.strip_edges()
	
	# 2. 处理空条件
	if cond.is_empty():
		return true
	
	# 3. 处理括号 - 如果整个表达式被括号包裹，先去掉
	cond = _unwrap_parentheses(cond)
	
	# 4. 查找最外层运算符的位置
	var op_pos = _find_outer_operator(cond)
	
	# 5. 如果有运算符，分割并递归
	if op_pos != -1:
		var op = cond[op_pos]
		var left = cond.substr(0, op_pos)
		var right = cond.substr(op_pos + 1)
		
		match op:
			"&":
				return conditional_judgement(left, experienced_events, current_status) and conditional_judgement(right, experienced_events, current_status)
			"|":
				return conditional_judgement(left, experienced_events, current_status) or conditional_judgement(right, experienced_events, current_status)
	
	# 6. 没有运算符，就是原子条件
	return parse_single(cond, experienced_events, current_status)


# 去掉最外层括号（如果整个表达式被括号包裹）
func _unwrap_parentheses(expr: String) -> String:
	var trimmed = expr.strip_edges()
	if not trimmed.begins_with("(") or not trimmed.ends_with(")"):
		return trimmed
	
	# 检查括号是否匹配整个表达式
	var depth = 0
	var is_fully_wrapped = true
	
	for i in trimmed.length():
		var c = trimmed[i]
		if c == "(":
			depth += 1
		elif c == ")":
			depth -= 1
			# 如果中途depth=0且还没到结尾，说明不是整体包裹
			if depth == 0 and i < trimmed.length() - 1:
				is_fully_wrapped = false
				break
	
	if is_fully_wrapped:
		return trimmed.substr(1, trimmed.length() - 2)
	
	return trimmed


# 查找最外层运算符的位置
func _find_outer_operator(expr: String) -> int:
	var depth = 0
	for i in expr.length():
		var c = expr[i]
		if c == "(":
			depth += 1
		elif c == ")":
			depth -= 1
		elif depth == 0 and (c == "&" or c == "|"):
			return i
	return -1

func parse_single(condition: String, experienced_events: Array, current_status: Dictionary) -> bool:
	# 处理多重括号（递归）
	if condition.count("(") > condition.count(")"):
		# 括号不匹配，可能是嵌套括号
		return conditional_judgement(condition, experienced_events, current_status)
	
	var cond = condition.replace("(", "").replace(")", "").strip_edges()
	
	# 判断是属性比较还是检查类型
	var calc = ""
	var value = []
	
	if ">" in cond:
		calc = ">"
		value = cond.split(">")
	elif "<" in cond:
		calc = "<"
		value = cond.split("<")
	elif "=" in cond:
		calc = "="
		value = cond.split("=")
	elif "?" in cond:
		calc = "?"
		value = cond.split("?")
	elif "!" in cond:
		calc = "!"
		value = cond.split("!")
	else:
		push_error("无法解析的条件: " + cond)
		return false
	
	if value.size() != 2:
		push_error("条件格式错误: " + cond)
		return false
	
	var left = value[0].strip_edges()
	var right = value[1].strip_edges()
	
	# 处理不同类型的检查
	match calc:
		">", "<", "=":
			# 属性比较
			var prop_value = _get_property_value(left, current_status)
			var compare_value = float(right)
			
			match calc:
				">": return prop_value > compare_value
				"<": return prop_value < compare_value
				"=": return prop_value == compare_value
		
		"?":
			# 检查存在性 (TLT? EVT? 等)
			return _check_exists(left, right, experienced_events, current_status, false)
		
		"!":
			# 检查不存在性 (EVT! 等)
			return _check_exists(left, right, experienced_events, current_status, true)
	
	return false


# 获取属性值
func _get_property_value(prop_name: String, current_status: Dictionary) -> float:
	# 先从PropertyData的枚举映射
	var type_enum = PropertyData._string_enum_types.get(prop_name)
	if type_enum != null:
		# 尝试从current_status获取
		return current_status.get(type_enum, 0.0)
	
	# 直接通过字符串获取
	return current_status.get(prop_name, 0.0)


# 检查存在性（天赋、事件等）
func _check_exists(left: String, right: String, experienced_events: Array, current_status: Dictionary, negate: bool) -> bool:
	var ids = _parse_ids(right)
	
	match left:
		"TLT":
			# 检查天赋
			var talents = current_status.get("TLT", [])
			for id in ids:
				var has = str(id) in talents
				if negate:
					if has:
						return false
				else:
					if has:
						return true
			return negate  # 如果取反，没找到就是true
		
		"EVT":
			# 检查本局事件
			for id in ids:
				var has = str(id) in experienced_events
				if negate:
					if has:
						return false
				else:
					if has:
						return true
			return negate
		
		"AEVT":
			# 检查全局事件
			var global_events = current_status.get("AEVT", [])
			for id in ids:
				var has = str(id) in global_events
				if negate:
					if has:
						return false
				else:
					if has:
						return true
			return negate
		
		"ATLT":
			# 检查全局天赋
			var global_talents = current_status.get("ATLT", [])
			for id in ids:
				var has = str(id) in global_talents
				if negate:
					if has:
						return false
				else:
					if has:
						return true
			return negate
		
		"ACHV":
			# 检查成就
			var achievements = current_status.get("ACHV", [])
			for id in ids:
				var has = str(id) in achievements
				if negate:
					if has:
						return false
				else:
					if has:
						return true
			return negate
		
		_:
			push_error("未知的检查类型: " + left)
			return false


# 解析ID列表，支持单个和多个
func _parse_ids(id_str: String) -> Array:
	var result = []
	id_str = id_str.replace("[", "").replace("]", "")
	
	if "," in id_str:
		var parts = id_str.split(",")
		for part in parts:
			result.append(int(part.strip_edges()))
	else:
		result.append(int(id_str))
	
	return result
