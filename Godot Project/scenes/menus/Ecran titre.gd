extends Control

func goto_scene(path):
	Utils.change_scene(self, path)
	
func _input(ev):
	if ev is InputEventKey or ev is InputEventJoypadButton:
		#get_tree().change_scene("res://scenes/menus/MenuPr.tscn")
		call_deferred("goto_scene", "res://scenes/menus/MenuPr.tscn")
