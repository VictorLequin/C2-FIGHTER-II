extends Label

func goto_scene(path):
	Utils.change_scene(self, path)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var bounds = Rect2(rect_position, rect_size)
		if bounds.has_point(event.position):
			#get_tree().change_scene("res://scenes/menus/Selection stage.tscn")
			call_deferred("goto_scene", "res://scenes/menus/Selection stage.tscn")
