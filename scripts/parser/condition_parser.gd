extends RefCounted
class_name ConditionParser

func parse_branch(branch: Array, experienced_events: Array, current_status: Dictionary) -> String:

	for item in branch:
		var parts = item.split(":")
		var condition = parts[0].replace(" ", "")
		var task_id = parts[1].replace(" ", "")
		
		var is_satisfied: bool = conditional_judgement(condition, experienced_events, current_status)
		if is_satisfied:
			return task_id  # 返回第一个满足的，不继续检查后面的
	
	return ""  # 没有满足的条件


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


# 检查存在性（支持所有枚举类型）
# 对应 JavaScript 中的 checkProp() 函数的 '?' 和 '!' 操作符
func _check_exists(left: String, right: String, experienced_events: Array, current_status: Dictionary, negate: bool) -> bool:
	var condition_data = _parse_condition_data(right)
	
	# 通过PropertyData获取枚举值
	var type_enum = PropertyData._string_enum_types.get(left)
	if type_enum == null:
		push_error("未知的检查类型: " + left)
		return false
	
	# 从current_status获取对应的值（propData）
	var prop_data = current_status.get(type_enum)
	if prop_data == null:
		# 如果current_status里没有，可能是数组类型需要特殊处理
		match left:
			"EVT", "AEVT", "TLT", "ATLT", "ACHV":
				prop_data = []
			_:
				prop_data = 0
	
	# 根据值的类型决定如何检查
	# 对应 JavaScript: case '?':
	if typeof(prop_data) == TYPE_ARRAY:
		# propData 是数组：检查 propData 中的任意元素是否在 conditionData 中
		# JavaScript: for(const p of propData) if(conditionData.includes(p)) return true;
		if typeof(condition_data) == TYPE_ARRAY:
			# conditionData 也是数组（如 [50482]）
			for p in prop_data:
				if p in condition_data:
					return not negate  # 找到了，如果是 '?' 返回 true，如果是 '!' 返回 false
			return negate  # 没找到，如果是 '?' 返回 false，如果是 '!' 返回 true
		else:
			# conditionData 是单个值
			var has = condition_data in prop_data
			return has if not negate else not has
	else:
		# propData 不是数组：检查 conditionData 是否包含 propData
		# JavaScript: return conditionData.includes(propData);
		if typeof(condition_data) == TYPE_ARRAY:
			var has = prop_data in condition_data
			return has if not negate else not has
		else:
			# 两者都是单个值，直接比较
			var has = prop_data == condition_data
			return has if not negate else not has

# 解析条件数据，支持单个值和数组
# 对应 JavaScript: const conditionData = d[0]=='['? JSON.parse(d): Number(d);
func _parse_condition_data(data_str: String):
	var trimmed = data_str.strip_edges()
	
	# 检查是否是数组格式 [xxx] 或 [xxx,yyy]
	if trimmed.begins_with("[") and trimmed.ends_with("]"):
		# 解析为数组
		var content = trimmed.substr(1, trimmed.length() - 2)  # 去掉 [ 和 ]
		
		if content.is_empty():
			return []
		
		if "," in content:
			# 多个值
			var parts = content.split(",")
			var result = []
			for part in parts:
				var cleaned = part.strip_edges()
				if cleaned.is_valid_int():
					result.append(int(cleaned))
				elif cleaned.is_valid_float():
					result.append(float(cleaned))
				else:
					result.append(cleaned)
			return result
		else:
			# 单个值，但仍返回数组
			var cleaned = content.strip_edges()
			if cleaned.is_valid_int():
				return [int(cleaned)]
			elif cleaned.is_valid_float():
				return [float(cleaned)]
			else:
				return [cleaned]
	else:
		# 不是数组格式，解析为单个数字
		if trimmed.is_valid_int():
			return int(trimmed)
		elif trimmed.is_valid_float():
			return float(trimmed)
		else:
			return trimmed

# 解析ID列表，支持单个和多个（保留用于向后兼容）
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
