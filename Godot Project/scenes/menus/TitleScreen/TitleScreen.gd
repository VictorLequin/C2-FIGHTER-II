extends Control

func _unhandled_input(event):
	if event.is_action("ui_accept"):
		get_node("/root/Node").load_menu("res://scenes/menus/MainMenu/MainMenu.tscn")
