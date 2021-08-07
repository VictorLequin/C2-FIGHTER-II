extends HBoxContainer

onready var main = get_node("/root/Node")

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("load_items")
	
func load_items():
	for controller in main.list_inactive():
		if controller.type == main.ControllerType.keyboard:
			if controller.id == main.KeyboardLayouts.wasd:
				add_child(load("res://scenes/menus/CharacterSelect/wasd.tscn").instance())
			if controller.id == main.KeyboardLayouts.arrows:
				add_child(load("res://scenes/menus/CharacterSelect/arrows.tscn").instance())
		else:
			add_child(load("res://scenes/menus/CharacterSelect/joypad.tscn").instance())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
