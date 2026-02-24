extends Node
class_name DataUtil

func init_data():
	if !FileAccess.file_exists("user://user_data.json"):
		var source_file = FileAccess.open("res://data/example/user_data.json",FileAccess.READ)
		var content = source_file.get_as_text()
		source_file.close()
		var dist_file = FileAccess.open("user://user_data.json", FileAccess.WRITE)
		dist_file.store_string(content)
		dist_file.close()
	else:
		pass

func get_data() -> Dictionary:
	var userdata = FileAccess.open("user://user_data.json",FileAccess.READ)
	if not userdata:
		return {}
	var content = userdata.get_as_text()
	var data = JSON.parse_string(content)
	if data != null:
		return data
	return {}

func update_data(new_data: Dictionary) -> bool:
	var userdata = FileAccess.open("user://user_data.json",FileAccess.WRITE)
	var res = userdata.store_string(JSON.stringify(new_data))
	if res == false:
		return false
	return true
