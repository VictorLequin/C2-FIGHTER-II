extends Control

var player
var ui_left: String
var ui_right: String

onready var lastUpdate = OS.get_ticks_msec()
const input_delay = 200 # ms

# Called when the node enters the scene tree for the first time.
func _ready():
	reload()

func _input(event):
	if Input.is_action_pressed(ui_left) and lastUpdate + input_delay < OS.get_ticks_msec():
		player.prevCharacter()
		lastUpdate = OS.get_ticks_msec()
		reload()
	if Input.is_action_pressed(ui_right) and lastUpdate + input_delay < OS.get_ticks_msec():
		player.nextCharacter()
		lastUpdate = OS.get_ticks_msec()
		reload()

func reload():
	get_node("Control/CharacterPic").texture = load(player.picPath())
