extends Control

func goto_scene(path):
	Utils.change_scene(self, path)

func _unhandled_input(event):
	if event.is_action("ui_accept"):
		#get_tree().change_scene("res://scenes/menus/MenuPr.tscn")
		call_deferred("goto_scene", "res://scenes/menus/MenuPr.tscn")
