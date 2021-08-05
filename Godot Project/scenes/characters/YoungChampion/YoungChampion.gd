extends "res://scenes/characters/Character.gd"

func _ready():
	offsets = {
		"idle": Vector2(-2.629, -1.602),
		"air": Vector2(-0.833, -2.744),
		"walk": Vector2(-2.053, -1.703),
		"jump": Vector2(-2.445, -1.703),
		"neutral": Vector2(21.605, -7.719),
		"side": Vector2(14.528, -2.762),
		"up": Vector2(2.552, -20.704)
	}
	walk_speed = 350
	air_acc = 200
	jump_speed = 450
	air_speed = 170
