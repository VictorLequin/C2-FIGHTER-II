extends Control

var player
var ui_left: String
var ui_right: String
var left_arrow
var right_arrow
var portrait
var cadre

onready var lastUpdate = OS.get_ticks_msec()
const input_delay = 200 # ms

# Called when the node enters the scene tree for the first time.
func _ready():
	portrait = $Control/CharacterPic
	cadre = $Control/Cadre
	left_arrow = $Control/Left
	right_arrow = $Control/Right
	var path
	if player.controller.type == 1:
		path = "res://ressources/menus/Joypad.png"
	else:
		if player.controller.id == 1:
			path = "res://ressources/menus/wasd.png"
		else:
			path = "res://ressources/menus/arrows.png"
	$Control/Controller.texture = load(path)
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
	portrait.texture = load(player.picPath())
	var color = player.color
	color.r = 1 - (1 - color.r)*2/3
	color.g = 1 - (1 - color.g)*2/3
	color.b = 1 - (1 - color.b)*2/3
	cadre.set_modulate(color)
