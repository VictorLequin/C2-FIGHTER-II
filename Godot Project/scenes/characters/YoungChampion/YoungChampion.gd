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
	attacks = {
		"neutral": {
			"knockback": Vector2(400, 200),
			"cancelable": true,
			"locking": true
		},
		"side": {
			"knockback": Vector2(600, 200),
			"cancelable": false,
			"locking": true
		},
		"up": {
			"knockback": Vector2(0, 300),
			"cancelable": true,
			"locking": false
		}
	}
	mass = 0.9

func update_dmgBox(delta):
	if hitting:
		atk_time += delta
		if atk == "side":
			var f = cst_interpol(1.0/15.0, atk_time)
			dmgBox.position.x = 46.104*f*direction
			dmgBox.position.y = -45.436
			dmgBox.shape.extents.x = 51.067*f
			dmgBox.shape.extents.y = 5.75*f
		if atk == "neutral":
			var f = cst_cst_interpol(1.0/15.0, 2.5/15.0, atk_time)
			dmgBox.position.x = 63.922*f*direction
			dmgBox.position.y = -69.936*f
			dmgBox.shape.extents.x = 33.917*f
			dmgBox.shape.extents.y = 39.604*f
		if atk == "up":
			var f = cst_cst_interpol(1.0/15.0, 2.5/15.0, atk_time)
			dmgBox.position.x = 13.586*f*direction
			dmgBox.position.y = -120.271*f
			dmgBox.shape.extents.x = 34.808*f
			dmgBox.shape.extents.y = 46.063*f
