extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	var main = get_node("/root/Node")

	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_0 :
		if main.joypad_join(event.device): get_tree().set_input_as_handled()
	
	elif event is InputEventKey:
		var layout = main.KeyboardLayouts.none
		if event.scancode == KEY_SPACE:
			layout = main.KeyboardLayouts.wasd
		elif event.scancode == KEY_KP_ENTER:
			layout = main.KeyboardLayouts.arrows
		
		if layout != main.KeyboardLayouts.none:
			if main.keyboard_join(layout): get_tree().set_input_as_handled()
	
	
	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_1 :
		if main.joypad_leave(event.device): get_tree().set_input_as_handled()
	
	elif event is InputEventKey:
		var layout = main.KeyboardLayouts.none
		if event.scancode == KEY_ESCAPE:
			layout = main.KeyboardLayouts.wasd
		elif event.scancode == KEY_KP_PERIOD:
			layout = main.KeyboardLayouts.arrows
		
		if layout != main.KeyboardLayouts.none:
			if main.keyboard_leave(layout): get_tree().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
