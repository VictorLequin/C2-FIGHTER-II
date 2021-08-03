extends Control

func _input(ev):
	if ev is InputEventKey or ev is InputEventJoypadButton:
		get_tree().change_scene("res://scenes/menus/MenuPr.tscn")
