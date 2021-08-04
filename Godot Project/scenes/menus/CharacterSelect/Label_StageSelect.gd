extends Label


func _input(event):
	# TODO replace by button
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var bounds = Rect2(rect_position, rect_size)
		if bounds.has_point(event.position):
			get_node("/root/Node").load_menu("res://scenes/menus/StageSelect/StageSelect.tscn")
