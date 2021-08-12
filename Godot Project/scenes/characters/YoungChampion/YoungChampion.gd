extends "res://scenes/characters/Character.gd"

var healing
var healingTime
var baby
var babyBox

func _ready():
	healing = false
	healingTime = 0
	offsets = {
		"idle": Vector2(-2.629, -1.602),
		"air": Vector2(-0.833, -2.744),
		"walk": Vector2(-2.189, -1.703),
		"jump": Vector2(-2.445, -1.703),
		"neutral": Vector2(21.605, -7.719),
		"side": Vector2(14.528, -2.762),
		"up": Vector2(2.552, -20.704),
		"spe_neutral": Vector2(0.524, 4.331),
		"spe_side": Vector2(22.493, -1.742),
		"spe_up": Vector2(2.577, -30.621),
		"spe_down": Vector2(0.514, -1.602),
		"spe_down_idle": Vector2(0.514, -1.602),
		"stun": Vector2(0.551, 2.318)
	}
	walk_speed = 350
	air_acc = 200
	jump_speed = 450
	air_speed = 200
	air_frott_lin = 0.7
	attacks = {
		"neutral": {
			"knockback": Vector2(400, 200),
			"cancelable": true,
			"locking": true,
			"percent": 3
		},
		"side": {
			"knockback": Vector2(600, 200),
			"cancelable": false,
			"locking": true,
			"percent": 3
		},
		"up": {
			"knockback": Vector2(0, 300),
			"cancelable": true,
			"locking": false,
			"percent": 3
		},
		"spe_neutral": {
			"cancelable": false,
			"locking": true,
			"percent": 5
		},
		"spe_side": {
			"cancelable": false,
			"locking": true,
			"percent": 5
		},
		"spe_up": {
			"cancelable": true,
			"locking": false
		},
		"spe_down": {
			"cancelable": true,
			"locking": false
		}
	}
	mass = 1.1
	baby = $Babyboule
	baby.id = id
	babyBox = $Babyboule/CollisionShape2D
	baby.players_hit = [id]

func update_dmgBox(delta):
	if hitting:
		atk_time += delta
		if atk == "side":
			var f = cst_interpol(1.0/15.0, atk_time)
			dmgBox.position.x = 46.104*f*direction
			dmgBox.position.y = -45.436
			dmgBox.scale.x = 51.067*f
			dmgBox.scale.y = 5.75*f
		if atk == "neutral":
			var f = cst_cst_interpol(1.0/15.0, 2.5/15.0, atk_time)
			dmgBox.position.x = 63.922*f*direction
			dmgBox.position.y = -69.936*f
			dmgBox.scale.x = 33.917*f
			dmgBox.scale.y = 39.604*f
		if atk == "up":
			var f = cst_cst_interpol(1.0/15.0, 2.5/15.0, atk_time)
			dmgBox.position.x = 13.586*f*direction
			dmgBox.position.y = -120.271*f
			dmgBox.scale.x = 34.808*f
			dmgBox.scale.y = 46.063*f
		if atk == "spe_side":
			var f = cst_lin_interpol(0.1, 0, 1.0, atk_time)
			f = 1 - abs(2*f - 1)
			baby.position.x = direction*(28.25 + 171*f)
			if baby.flip == 1 and atk_time >= 0.55:
				baby.flip = -1
				atk_id += 1
				baby.atk_id = atk_id
				baby.players_hit = [id]
		if atk == "spe_neutral":
			if atk_time >= 5.0/15.0:
				babyBox.set_deferred("disabled", false)

func end_anim_fn():
	if atk == "spe_side" or atk == "spe_neutral":
		baby.vanish()
	if atk != "spe_down":
		.end_anim_fn()
	else:
		healing = true
		healingTime = 0
		play("spe_down_idle")

func end_hit():
	healing = false
	.end_hit()

func spe_side_start():
	babyBox.set_deferred("disabled", false)
	baby.atk_id = atk_id
	baby.position.x = direction*abs(baby.position.x)

func spe_neutral_start():
	baby.position.x = 0
	baby.atk_id = atk_id
	baby.scale.x = 22
	baby.scale.y = 22

func _input(event):
	if event.is_action_released(ui_down) and atk == "spe_down" and hitting:
		end_hit()

func _physics_process(delta):
	if healing:
		healingTime += delta
		var bonus = healingTime
		if bonus > 1:
			bonus = 1
		percent -= (3 + bonus)*delta
		if percent < 0:
			percent = 0
