extends HBoxContainer

onready var main = get_node("/root/Node")

func _ready():
	call_deferred("load_items")
	
func load_items():
	var wasd = false
	var arrows = false
	for controller in main.list_inactive():
		if controller.type == main.ControllerType.keyboard:
			if controller.id == main.KeyboardLayouts.wasd:
				wasd = true
			if controller.id == main.KeyboardLayouts.arrows:
				arrows = true
		else:
			add_child(load("res://scenes/menus/CharacterSelect/joypad.tscn").instance())
	if wasd and arrows:
		add_child(load("res://scenes/menus/CharacterSelect/clavier.tscn").instance())
	elif wasd:
		add_child(load("res://scenes/menus/CharacterSelect/wasd.tscn").instance())
	elif arrows:
		add_child(load("res://scenes/menus/CharacterSelect/arrows.tscn").instance())
