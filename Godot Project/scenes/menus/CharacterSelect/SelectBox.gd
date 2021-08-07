extends Control

var player
var ui_left: String
var ui_right: String


# Called when the node enters the scene tree for the first time.
func _ready():
	reload()

func _input(event):
	if event.is_action_pressed(ui_left):
		player.prevCharacter()
		reload()
	if event.is_action_pressed(ui_right):
		player.nextCharacter()
		reload()

func reload():
	get_node("Control/CharacterPic").texture = load(player.picPath())
