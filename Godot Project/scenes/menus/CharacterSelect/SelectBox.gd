extends Control

var player
var ui_left: String
var ui_right: String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed(ui_left):
		pass
	if event.is_action_pressed(ui_right):
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
