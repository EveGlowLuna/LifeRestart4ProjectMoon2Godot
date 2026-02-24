extends Node

func process(data: Array) -> Array:
	"""将不统一的id格式转化为统一格式(int->str)"""
	var parsed_data = []
	for item in data:
		if typeof(item) == TYPE_INT:
			parsed_data.append(str(item))
		else:
			parsed_data.append(item)
	
	return parsed_data

# 解析单个事件字符串，返回 {id: "1001", weight: 0.2} 格式
func parse_event(event_str: String) -> Dictionary:
	# 检查是否包含 * 
	if "*" in event_str:
		var parts = event_str.split("*")
		var id = parts[0]
		# 解析权重，如果是无效数字则默认1.0
		var weight = float(parts[1]) if parts[1].is_valid_float() else 1.0
		return {"id": id, "weight": weight}
	else:
		# 没有 * 表示权重为 1
		return {"id": event_str, "weight": 1.0}

# 从事件数组中随机抽取一个（带权重）
func random_select(events: Array) -> String:
	if events.is_empty():
		return ""
	
	# 第一步：解析所有事件，计算总权重
	var parsed_events = []
	var total_weight: float = 0.0
	
	for event_str in events:
		var parsed = parse_event(event_str)
		parsed_events.append(parsed)
		total_weight += parsed.weight
	
	# 第二步：随机选择一个点
	var random_point = randf() * total_weight
	
	# 第三步：遍历找到选中的事件
	var current_sum: float = 0.0
	for parsed in parsed_events:
		current_sum += parsed.weight
		if random_point < current_sum:
			return parsed.id
	
	# 容错：返回最后一个
	return parsed_events[-1].id if not parsed_events.is_empty() else ""
