extends Label


func _input(event):
	# TODO replace by button
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var bounds = Rect2(rect_position, rect_size)
		if bounds.has_point(event.position):
			var main = get_node("/root/Node")
			if main.players.count() > 0:
				main.load_menu("res://scenes/menus/StageSelect/StageSelect.tscn")
			else:
				print("Argh! No players joined!")
