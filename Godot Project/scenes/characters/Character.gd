extends KinematicBody2D

var screen_size
var on_ground
var sprite
var velocity
export var walk_speed = 200
export var air_acc = 100
export var ground_frott_quad = 0.3
export var ground_frott_stat = 1
var direction
export var jump_speed = 350
var jump_count
export var air_speed = 100
export var gravity = 1500
export var mass = 1.6
export var offsets = {
	"idle": Vector2(-2.336, -0.65),
	"air": Vector2(-0.434, -0.65),
	"walk": Vector2(-1.489, -0.65),
	"jump": Vector2(-1.435, -1.595),
	"neutral": Vector2(2.254, -3.725),
	"side": Vector2(28.702, -3.643),
	"up": Vector2(0.621, -25.622),
	"spe_neutral": Vector2(-0.44, -2.713),
	"spe_side": Vector2(25.579, -3.76),
	"spe_up": Vector2(-0.499, 14.328)
}
export var attacks = {
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
		"cancelable": false,
		"locking": true
	},
	"spe_up": {
		"cancelable": true,
		"locking": false
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
var unsnapped
var players_hit
var end_anim

var ui_jump: String = ""
var ui_up: String = ""
var ui_action: String = ""
var ui_right: String = ""
var ui_left: String = ""
var ui_spe: String = ""

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
	end_anim = false
	playing = ""
	atk = ""
	atk_time = 0
	unsnapped = false
	players_hit = [ui_jump]
	sprite.connect("animation_finished", self, "animation_finished_handler")
	$DamageArea.connect("body_entered", self, "enemy_hit")

func enemy_hit(enemy):
	if enemy.has_method("enemy_hit"): # Player object detection
		if not players_hit.has(enemy.ui_jump):
			players_hit.append(enemy.ui_jump)
			enemy.velocity.x += attacks[atk].knockback.x*direction/enemy.mass
			enemy.velocity.y -= attacks[atk].knockback.y/enemy.mass
			enemy.unsnapped = true

func end_hit():
	hitting = false
	dmgBox.set_deferred("disabled", true)
	dmgBox.position.y = 0
	dmgBox.position.x = 0
	dmgBox.shape.extents.x = 0
	dmgBox.shape.extents.y = 0
	players_hit = [ui_jump]

func spe_up():
	pass

func spe_neutral():
	pass

func spe_side():
	pass

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
			hitting = true
			play(wanted_atk)
			atk = wanted_atk
			dmgBox.set_deferred("disabled", false)
			atk_time = 0
	if event.is_action_pressed(ui_up):
		holding_up = true
	if event.is_action_released(ui_up):
		holding_up = false
	if event.is_action_pressed(ui_spe):
		var wanted_atk
		if holding_up:
			wanted_atk = "spe_up"
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
			hitting = true
			atk = wanted_atk
			play(wanted_atk)
			if holding_up:
				spe_up()
			else:
				if not siding:
					spe_neutral()
				else:
					spe_side()

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
			dmgBox.shape.extents.x = 54.39*f
			dmgBox.shape.extents.y = 10.347*f
		if atk == "neutral":
			var f = cst_interpol(3.0/13.0, atk_time)
			dmgBox.position.x = 48*f*direction
			dmgBox.position.y = -64*f
			dmgBox.shape.extents.x = 33.936*f
			dmgBox.shape.extents.y = 71.656*f
		if atk == "up":
			var f = cst_cst_interpol(2.0/15.0, 4.5/15.0, atk_time)
			dmgBox.position.x = 9.27*f*direction
			dmgBox.position.y = -119.19*f
			dmgBox.shape.extents.x = 46.445*f
			dmgBox.shape.extents.y = 37.715*f

func _physics_process(delta):
	if end_anim:
		end_anim = false
		playing = ""
		jumping = false
		end_hit()
	update_dmgBox(delta)
	if not on_ground and is_on_floor():
		jump_count = 1
		jumping = false
		velocity.x = 0
	on_ground = is_on_floor()
	siding = false
	var last_vel = velocity
	var force = Vector2()
	var vel_walk = Vector2()
	var vel_air = Vector2()
	if not on_ground:
		force.y += gravity
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
	var vel_add = Vector2()
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
	if position.y > screen_size.y:
		position.y = 0
	if position.x > screen_size.x + 100:
		position.x = 0
	if position.x < -1000:
		position.x = screen_size.x
