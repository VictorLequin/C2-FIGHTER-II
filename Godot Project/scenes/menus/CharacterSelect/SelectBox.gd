extends Control

var player
var ui_left: String
var ui_right: String
var left_arrow
var right_arrow

onready var lastUpdate = OS.get_ticks_msec()
const input_delay = 200 # ms

# Called when the node enters the scene tree for the first time.
func _ready():
	left_arrow = $Control/Left
	right_arrow = $Control/Right
	reload()

func _input(event):
	if Input.is_action_pressed(ui_left) and lastUpdate + input_delay < OS.get_ticks_msec():
		player.prevCharacter()
		lastUpdate = OS.get_ticks_msec()
		left_arrow.press()
		reload()
	if Input.is_action_pressed(ui_right) and lastUpdate + input_delay < OS.get_ticks_msec():
		player.nextCharacter()
		lastUpdate = OS.get_ticks_msec()
		right_arrow.press()
		reload()

func reload():
	get_node("Control/CharacterPic").texture = load(player.picPath())
