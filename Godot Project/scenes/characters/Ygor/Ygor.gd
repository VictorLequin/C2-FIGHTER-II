extends "res://scenes/characters/Character.gd"

var spe_up_count
var spe_up_speed
var flaqued

func _ready():
	flaqued = false
	offsets = {
		"idle": Vector2(-0.345, -3.547),
		"air": Vector2(1.666, -0.769),
		"walk": Vector2(-2.189, -1.703),
		"jump": Vector2(-0.22, -2.067),
		"neutral": Vector2(11.775, -3.625),
		"side": Vector2(26.719, -6.672),
		"up": Vector2(-0.342, -17.622),
		"spe_neutral": Vector2(0.768, -20.719),
		"spe_side": Vector2(-2.24, -1.608),
		"spe_up": Vector2(-1.342, -76.714),
		"spe_down": Vector2(-0.219, -3.667),
		"stun": Vector2(-1.342, -3.666),
		"ledge": Vector2(1.139, -1.699),
		"down": Vector2(-1.297, 10.339),
		"roll": Vector2(29.719, -6.672),
		"spe_down_air": Vector2(-0.345, -3.547),
		"flaquing": Vector2(-0.345, -3.547)
	}
	walk_speed = 250.0
	air_acc = 150.0
	jump_speed = 400
	air_speed = 180
	air_frott_lin = 0.7
	attacks = {
		"neutral": {
			"knockback": Vector2(350.0, 100.0),
			"cancelable": true,
			"locking": true,
			"percent": 5
		},
		"side": {
			"knockback": Vector2(520.0, 100.0),
			"cancelable": false,
			"locking": true,
			"percent": 4
		},
		"up": {
			"knockback": Vector2(0, 80.0),
			"cancelable": true,
			"locking": false,
			"percent": 6
		},
		"down": {
			"knockback": Vector2(0, -150.0),
			"cancelable": true,
			"locking": false,
			"percent": 4
		},
		"spe_neutral": {
			"cancelable": false,
			"locking": false,
			"percent": 10
		},
		"spe_side": {
			"cancelable": false,
			"locking": true
		},
		"spe_up": {
			"cancelable": false,
			"locking": false
		},
		"spe_down": {
			"cancelable": true,
			"locking": false
		}
	}
	spe_up_count = 0
	spe_up_speed = 200.0
	mass = 1.3
	ledgeShift = Vector2(54.7, 108.8)
	sounds = {}
	ready_sounds()

func end_anim_fn():
	if atk == "spe_up":
		spe_up_speed = 100.0
	if playing == "spe_down":
		flaqued = true
		invincible = true
		play("flaquing")
	elif playing != "spe_down_air" and playing != "flaquing":
		.end_anim_fn()

func end_hit():
	flaqued = false
	.end_hit()

func land():
	spe_up_count = 1
	if playing == "spe_down_air":
		flaqued = true
		invincible = true
		play("flaquing")
	.land()

func spe_up_vel(delta):
	spe_up_speed += 500.0*delta
	return Vector2(0, -spe_up_speed)

func spe_up_acc():
	return Vector2(0, -gravity)

func spe_up_start():
	if spe_up_count > 0:
		velocity.y = 0
		dmgBox.set_deferred("disabled", false)
		spe_up_count -= 1
		unsnapped = true
	else:
		end_hit()

func spe_down_start():
	if not on_ground:
		play("spe_down_air")

func update_dmgBox(delta):
	if state == STATE.HITTING:
		atk_time += delta
		if atk == "side":
			var f = cst_lin_cst_interpol(1.0/15.0, 0, 3.0/15.0, 1, atk_time)
			dmgBox.position.x = 47.16*f*direction
			dmgBox.position.y = -63.013
			dmgBox.scale.x = 47.866*f
			dmgBox.scale.y = 8.839*f
		if atk == "neutral":
			var f = cst_cst_interpol(3.0/15.0, 5/15.0, atk_time)
			dmgBox.position.x = 52.065*f*direction
			dmgBox.position.y = -51.183*f
			dmgBox.scale.x = 30.927*f
			dmgBox.scale.y = 47.56*f
		if atk == "up":
			var f = cst_lin_cst_interpol(3.0/15.0, 0.3, 7.0/15.0, 1, atk_time)
			dmgBox.position.x = 1.752*f*direction
			dmgBox.position.y = -134.88*f
			dmgBox.scale.x = 51.28*f
			dmgBox.scale.y = 31.114*f
		if atk == "down":
			var f = cst_cst_interpol(3.0/12.0, 5.5/12.0, atk_time)
			dmgBox.position.x = -3.917*f*direction
			dmgBox.position.y = 11.348*f
			dmgBox.scale.x = 8.667*f
			dmgBox.scale.y = 27.5*f
		if atk == "spe_neutral":
			var f = cst_cst_interpol(12.0/15.0, 18.8/15.0, atk_time)
			dmgBox.position.x = 2.718*f*direction
			dmgBox.position.y = -127.747*f
			dmgBox.scale.x = 98.499*f
			dmgBox.scale.y = 112.034*f

func calc_vel_add(delta):
	var vel_add = Vector2()
	if state == STATE.HITTING:
		if atk == "spe_neutral":
			vel_add += spe_neutral_vel(delta)
		elif atk == "spe_side":
			vel_add += spe_side_vel(delta)
		elif atk == "spe_up":
			vel_add += spe_up_vel(delta)
		elif atk == "spe_down":
			vel_add += spe_down_vel(delta)
	var vel_walk = Vector2()
	var vel_air = Vector2()
	if Input.is_action_pressed(ui_right) and state != STATE.ROLLING:
		vel_walk.x += walk_speed
		vel_air.x += air_speed
	if Input.is_action_pressed(ui_left) and state != STATE.ROLLING:
		vel_walk.x -= walk_speed
		vel_air.x -= air_speed
	walking = false
	if vel_walk.length() > 0:
		walking = true
	if (state != STATE.HITTING or atk == "spe_neutral") and state != STATE.STUNNED:
		if on_ground:
			vel_add += vel_walk
		else:
			vel_add += vel_air
	if state == STATE.LEDGING:
		vel_add.x = direction*min(direction*vel_add.x, 0)
		if vel_add.length() > 0:
			unledge()
	return vel_add

func _input(event):
	if event.is_action_released(ui_down) and atk == "spe_down" and state == STATE.HITTING:
		invincible = false
		end_hit()
