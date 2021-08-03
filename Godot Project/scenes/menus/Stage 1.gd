extends Label

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var bounds = Rect2(rect_position, rect_size)
		if bounds.has_point(event.position):
			get_tree().change_scene("res://scenes/stages/Stage 1/Stage 1.tscn")
