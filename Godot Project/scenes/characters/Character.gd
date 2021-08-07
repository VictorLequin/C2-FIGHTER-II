extends KinematicBody2D

var screen_size
var on_ground
var sprite
var velocity
var walk_speed = 200
var air_acc = 100
var ground_frott_quad = 0.3
var ground_frott_stat = 1
var air_frott_lin = 0.5
var direction
var jump_speed = 350
var jump_count
var air_speed = 170
var gravity = 1500
var mass = 1.4
var offsets = {
	"idle": Vector2(-2.336, -0.65),
	"air": Vector2(-0.434, -0.65),
	"walk": Vector2(-1.489, -0.65),
	"jump": Vector2(-1.435, -1.595),
	"neutral": Vector2(2.254, -3.725),
	"side": Vector2(28.702, -3.643),
	"up": Vector2(0.621, -25.622),
	"spe_neutral": Vector2(-0.44, -2.713),
	"spe_side": Vector2(25.579, -3.76),
	"spe_up": Vector2(-0.499, 14.328),
	"spe_down": Vector2(2.58, 0.226)
}
var attacks = {
	"neutral": {
		"knockback": Vector2(600, 300),
		"cancelable": true,
		"locking": true # peut-on tourner pdt l'attaque ?
	},
	"side": {
		"knockback": Vector2(900, 300),
		"cancelable": false,
		"locking": true
	},
	"up": {
		"knockback": Vector2(0, 500),
		"cancelable": true,
		"locking": false
	},
	"spe_neutral": {
		"cancelable": false,
		"locking": true
	},
	"spe_side": {
		"knockback": Vector2(700, 200),
		"cancelable": false,
		"locking": true
	},
	"spe_up": {
		"knockback": Vector2(0, 300),
		"cancelable": true,
		"locking": false
	},
	"spe_down": {
		"cancelable": true,
		"locking": true
	}
}
var jumping
var hitting
var siding
var playing
var dmgBox
var atk_time
var atk
var holding_up
var holding_down
var unsnapped
var players_hit
var end_anim
var pending_kbs
var id

var ui_jump: String = ""
var ui_up: String = ""
var ui_action: String = ""
var ui_right: String = ""
var ui_left: String = ""
var ui_spe: String = ""
var ui_down: String = ""

func play(anim):
	playing = anim
	sprite.play(anim)
	sprite.offset = offsets[anim]

func animation_finished_handler():
	end_anim = true

func _ready():
	screen_size = get_viewport_rect().size
	on_ground = false
	sprite = $AnimatedSprite
	dmgBox = $DamageArea/CollisionShape2D
	velocity = Vector2()
	direction = 1
	jump_count = 0
	jumping = false
	hitting = false
	siding = false
	holding_up = false
	holding_down = false
	end_anim = false
	playing = ""
	atk = ""
	atk_time = 0
	unsnapped = false
	pending_kbs = []
	sprite.connect("animation_finished", self, "animation_finished_handler")
	$DamageArea.connect("body_entered", self, "enemy_hit")

func setup_id(k):
	ui_jump = "ui_jump_{k}".format({"k": k})
	ui_action = "ui_action_{k}".format({"k": k})
	ui_left = "ui_left_{k}".format({"k": k})
	ui_right = "ui_right_{k}".format({"k": k})
	ui_up = "ui_up_{k}".format({"k": k})
	ui_spe = "ui_spe_{k}".format({"k": k})
	ui_down = "ui_down_{k}".format({"k": k})
	id = k
	players_hit = [id]

func enemy_hit(enemy):
	if enemy.has_method("enemy_hit"): # Player object detection
		if not players_hit.has(enemy.id):
			players_hit.append(enemy.id)
			enemy.pending_kbs.append({
				"knockback": Vector2(attacks[atk].knockback.x*direction/enemy.mass, -attacks[atk].knockback.y/enemy.mass),
				"dealer": id
			})

func end_hit():
	hitting = false
	atk = ""
	dmgBox.scale.x = 1
	dmgBox.scale.y = 1
	dmgBox.set_deferred("disabled", true)
	dmgBox.position.y = 0
	dmgBox.position.x = 0
	players_hit = [id]

func spe_up_start():
	pass

func spe_neutral_start():
	pass

func spe_side_start():
	pass

func spe_down_start():
	pass

func spe_up_vel(delta):
	return Vector2()

func spe_neutral_vel(delta):
	return Vector2()

func spe_side_vel(delta):
	return Vector2()

func spe_down_vel(delta):
	return Vector2()

func spe_up_acc(delta):
	return Vector2()

func spe_neutral_acc(delta):
	return Vector2()

func spe_side_acc(delta):
	return Vector2()

func spe_down_acc(delta):
	return Vector2()

func _input(event):
	if event.is_action_pressed(ui_jump) and (on_ground or jump_count > 0):
		var allowed_to_jump = not hitting
		if hitting:
			if attacks[atk].cancelable:
				allowed_to_jump = true
		if allowed_to_jump:
			velocity.y = -jump_speed
			if not on_ground:
				jump_count -= 1
			jumping = true
			end_hit()
			play("jump")
	if event.is_action_pressed(ui_action):
		var wanted_atk
		if holding_up:
			wanted_atk = "up"
		else:
			if not siding:
				wanted_atk = "neutral"
			else:
				wanted_atk = "side"
		var allowed_to_hit = not hitting
		if hitting and wanted_atk != atk:
			if attacks[atk].cancelable:
				allowed_to_hit = true
		if allowed_to_hit:
			if hitting:
				end_hit()
			hitting = true
			play(wanted_atk)
			atk = wanted_atk
			dmgBox.set_deferred("disabled", false)
			atk_time = 0
	if event.is_action_pressed(ui_up):
		holding_up = true
	if event.is_action_released(ui_up):
		holding_up = false
	if event.is_action_pressed(ui_down):
		holding_down = true
	if event.is_action_released(ui_down):
		holding_down = false
	if event.is_action_pressed(ui_spe):
		var wanted_atk
		if holding_up:
			wanted_atk = "spe_up"
		elif holding_down:
			wanted_atk = "spe_down"
		else:
			if not siding:
				wanted_atk = "spe_neutral"
			else:
				wanted_atk = "spe_side"
		var allowed_to_hit = not hitting
		if hitting and wanted_atk != atk:
			if attacks[atk].cancelable:
				allowed_to_hit = true
		if allowed_to_hit:
			if hitting:
				end_hit()
			hitting = true
			atk = wanted_atk
			play(wanted_atk)
			atk_time = 0
			if holding_up:
				spe_up_start()
			elif holding_down:
				spe_down_start()
			else:
				if not siding:
					spe_neutral_start()
				else:
					spe_side_start()

func cst_interpol(step_t, time):
	var res = 0
	if time >= step_t:
		res = 1
	return res

func cst_cst_interpol(step1_t, step2_t, time):
	var res = 0
	if time >= step1_t and time < step2_t:
		res = 1
	return res

func lin_interpol(total, time):
	return time/total

func cst_lin_interpol(step_t, step, total, time):
	var res = 0
	if time >= step_t:
		res = step + (1 - step)*(time-step_t)/(total-step_t)
	return res

func cst_sqrt_interpol(step_t, step, total, time):
	var res = 0
	if time >= step_t:
		res = step + (1 - step)*sqrt((time-step_t)/(total-step_t))
	return res

func update_dmgBox(delta):
	if hitting:
		atk_time += delta
		if atk == "side":
			var f = cst_sqrt_interpol(0.2, 1/2, 0.7, atk_time)
			dmgBox.position.x = 61.714*f*direction
			dmgBox.position.y = -52.384
			dmgBox.scale.x = 54.39*f
			dmgBox.scale.y = 10.347
		if atk == "neutral":
			var f = cst_interpol(3.0/13.0, atk_time)
			dmgBox.position.x = 48*f*direction
			dmgBox.position.y = -64*f
			dmgBox.scale.x = 33.936*f
			dmgBox.scale.y = 71.656*f
		if atk == "up":
			var f = cst_cst_interpol(2.0/15.0, 4.5/15.0, atk_time)
			dmgBox.position.x = 9.27*f*direction
			dmgBox.position.y = -119.19*f
			dmgBox.scale.x = 46.445*f
			dmgBox.scale.y = 37.715*f

func land():
	jump_count = 1
	jumping = false
	velocity.x = 0

func end_anim_fn():
	playing = ""
	jumping = false
	end_hit()

func _physics_process(delta):
	if end_anim:
		end_anim = false
		end_anim_fn()
	update_dmgBox(delta)
	for boost in pending_kbs:
		velocity += boost.knockback
	pending_kbs = []
	var vel_add = Vector2()
	var force = Vector2()
	if hitting:
		if atk == "spe_neutral":
			vel_add += spe_neutral_vel(delta)
			force += spe_neutral_acc(delta)
		elif atk == "spe_side":
			vel_add += spe_side_vel(delta)
			force += spe_side_acc(delta)
		elif atk == "spe_up":
			vel_add += spe_up_vel(delta)
			force += spe_up_acc(delta)
		elif atk == "spe_down":
			vel_add += spe_down_vel(delta)
			force += spe_down_acc(delta)
	if not on_ground and is_on_floor():
		land()
	on_ground = is_on_floor()
	siding = false
	var last_vel = velocity
	var vel_walk = Vector2()
	var vel_air = Vector2()
	if not on_ground:
		force.y += gravity
		force -= air_frott_lin*velocity
	var direction_new = 0
	if Input.is_action_pressed(ui_right):
		siding = true
		direction_new = 1
		vel_walk.x += walk_speed
		vel_air.x += air_speed
		if not on_ground:
			force.x += air_acc/max(1, velocity.length()/200)
	if Input.is_action_pressed(ui_left):
		siding = true
		vel_walk.x -= walk_speed
		direction_new = -1
		vel_air.x -= air_speed
		if not on_ground:
			force.x -= air_acc/max(1, velocity.length()/200)
	if on_ground:
		force.x -= ground_frott_quad*velocity.x*abs(velocity.x)
		if velocity.x != 0:
			force.x -= ground_frott_stat*velocity.x/abs(velocity.x)
	var prev_velx = velocity.x
	velocity += force*delta
	if on_ground and velocity.x * prev_velx < 0:
		velocity.x = 0
	if direction * direction_new == -1:
		if not hitting:
			direction = direction_new
			sprite.scale.x = 3*direction
		else:
			if not attacks[atk].locking:
				direction = direction_new
				sprite.scale.x = 3*direction
	if not hitting:
		if on_ground:
			vel_add += vel_walk
		else:
			vel_add += vel_air
	if not jumping and not hitting:
		if on_ground:
			if vel_walk.length() > 0:
				play("walk")
			else:
				play("idle")
		else:
			if velocity.length() >= 350:
				play("air")
			else:
				play("idle")
	var snap = Vector2(0, 1)
	if jumping or unsnapped:
		snap = Vector2.ZERO
	if not on_ground:
		unsnapped = false
	velocity = move_and_slide_with_snap((velocity + last_vel)/2.0 + vel_add, snap, Vector2(0, -1))
	if abs(velocity.x) >= abs(vel_add.x):
		velocity.x -= vel_add.x
	if abs(velocity.y) >= abs(vel_add.y):
		velocity.y -= vel_add.y
	# TEMP
	if position.y > 1000:
		position = Vector2(0, 0)
