class_name DataUtil

var data: Dictionary = {}

func _init():
	init_data()
	load_data()

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

func load_data():
	var userdata = FileAccess.open("user://user_data.json",FileAccess.READ)
	if not userdata:
		return
	var content = userdata.get_as_text()
	var userdatavalue = JSON.parse_string(content)
	if userdatavalue != null:
		data = userdatavalue.duplicate(true)


func update_data() -> bool:
	var userdata = FileAccess.open("user://user_data.json",FileAccess.WRITE)
	var res = userdata.store_string(JSON.stringify(data))
	if res == false:
		return false
	return true
