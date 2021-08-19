extends KinematicBody2D

var screen_size
var on_ground
var sprite
var velocity
var last_vel
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
	"spe_down": Vector2(2.58, 0.226),
	"stun": Vector2(0.528, -1.744),
	"ledge": Vector2(0.609, -3.412)
}
var attacks = {
	"neutral": {
		"knockback": Vector2(600, 300),
		"cancelable": true,
		"locking": true, # peut-on tourner pdt l'attaque ?
		"percent": 6
	},
	"side": {
		"knockback": Vector2(900, 300),
		"cancelable": false,
		"locking": true,
		"percent": 6
	},
	"up": {
		"knockback": Vector2(0, 500),
		"cancelable": true,
		"locking": false,
		"percent": 6
	},
	"spe_neutral": {
		"cancelable": false,
		"locking": false
	},
	"spe_side": {
		"knockback": Vector2(700, 200),
		"cancelable": false,
		"locking": true,
		"percent": 9
	},
	"spe_up": {
		"knockback": Vector2(0, 300),
		"cancelable": true,
		"locking": false,
		"percent": 9
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
var pending_hits
var id
var blocked
var atk_id
var percent
var stunned
var red_highlight_time
var last_position
var damageArea
var hitBox
var ledging
var ledgeShift = Vector2(26.3, 101.8)
var allowed_to_ledge
var ledgeTimer
var sounds = {}
var playing_sound

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

func play_sound(sound):
	if sounds.has(sound):
		if playing_sound.size() > 1:
			sounds[playing_sound[0]][playing_sound[1]].stop()
		var i = randi() % sounds[sound].size()
		sounds[sound][randi() % sounds[sound].size()].play()
		playing_sound = [sound, i]

func end_sound():
	playing_sound = [""]

func ready_sounds():
	for s in sounds:
		for so in sounds[s]:
			so.connect("finished", self, "end_sound")

func animation_finished_handler():
	end_anim = true

func _ready():
	screen_size = get_viewport_rect().size
	allowed_to_ledge = true
	playing_sound = [""]
	ledging = false
	on_ground = false
	sprite = $AnimatedSprite
	dmgBox = $DamageArea/CollisionShape2D
	hitBox = $CollisionShape2D
	velocity = Vector2()
	last_vel = Vector2()
	direction = 1
	jump_count = 0
	jumping = false
	hitting = false
	siding = false
	holding_up = false
	holding_down = false
	end_anim = false
	stunned = 0
	playing = ""
	atk = ""
	atk_time = 0
	atk_id = 0
	unsnapped = false
	pending_hits = []
	blocked = []
	percent = 0
	red_highlight_time = 0
	last_position = position
	sprite.connect("animation_finished", self, "animation_finished_handler")
	damageArea = $DamageArea
	damageArea.atk_id = 0
	damageArea.connect("body_entered", self, "enemy_hit")
	damageArea.id = id
	ledgeTimer = $LedgeTimer
	ledgeTimer.connect("timeout", self, "allow_ledge")

func allow_ledge():
	allowed_to_ledge = true

func setup_id(k):
	ui_jump = "ui_jump_{k}".format({"k": k})
	ui_action = "ui_action_{k}".format({"k": k})
	ui_left = "ui_left_{k}".format({"k": k})
	ui_right = "ui_right_{k}".format({"k": k})
	ui_up = "ui_up_{k}".format({"k": k})
	ui_spe = "ui_spe_{k}".format({"k": k})
	ui_down = "ui_down_{k}".format({"k": k})
	id = k
	players_hit = [k]

func enemy_hit(enemy):
	if enemy.has_method("get_atk_percent_parent"): # Player object detection
		if not players_hit.has(enemy.id):
			players_hit.append(enemy.id)
			enemy.pending_hits.append({
				"knockback": Vector2(attacks[atk].knockback.x*direction/enemy.mass*(1 + enemy.percent/100), -attacks[atk].knockback.y/enemy.mass*(1 + enemy.percent/100)),
				"dealer": str(id) + "." + str(atk_id),
				"percent": attacks[atk].percent/enemy.mass
			})
			play_sound("tiens")

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

func spe_up_vel():
	return Vector2.ZERO

func spe_neutral_vel():
	return Vector2.ZERO

func spe_side_vel():
	return Vector2.ZERO

func spe_down_vel():
	return Vector2.ZERO

func spe_up_acc():
	return Vector2.ZERO

func spe_neutral_acc():
	return Vector2.ZERO

func spe_side_acc():
	return Vector2.ZERO

func spe_down_acc():
	return Vector2.ZERO

func _input(event):
	if event.is_action_pressed(ui_jump) and (on_ground or jump_count > 0):
		var allowed_to_jump = not hitting
		if hitting:
			if attacks[atk].cancelable:
				allowed_to_jump = true
		if allowed_to_jump and stunned <= 0:
			velocity.y = -jump_speed
			if not on_ground and not ledging:
				jump_count -= 1
			if ledging:
				unledge()
			jumping = true
			end_hit()
			play("jump")
			play_sound("jump")
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
		if allowed_to_hit and stunned <= 0:
			if ledging:
				unledge()
			atk_id += 1
			damageArea.atk_id += 1
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
		if allowed_to_hit and stunned <= 0:
			if ledging:
				unledge()
			atk_id += 1
			damageArea.atk_id += 1
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

func change_direction(new_direction):
	direction = new_direction
	sprite.scale.x = 3*direction

func get_atk_percent_parent():
	if atk == "":
		return 0
	else:
		return attacks[atk].percent

func stun(time):
	end_hit()
	play("stun")
	stunned = time
	pass

func unledge():
	ledging = false
	ledgeTimer.start(0.5)

func take_hit():
	if ledging:
		unledge()
	velocity /= 2
	sprite.set_modulate(Color(2,1,1,1))
	red_highlight_time = 0.1
	play_sound("ouch")

func _physics_process(delta):
	last_vel = velocity
	if stunned > 0:
		stunned -= delta
	if red_highlight_time > 0:
		red_highlight_time -= delta
		if red_highlight_time <= 0:
			sprite.set_modulate(Color(1,1,1,1))
	if end_anim:
		end_anim = false
		end_anim_fn()
	update_dmgBox(delta)
	var is_hit = false
	for hit in pending_hits:
		if not hit.dealer in blocked:
			is_hit = true
	if is_hit:
		take_hit()
	for hit in pending_hits:
		if not hit.dealer in blocked:
			velocity += hit.knockback
			percent += hit.percent
	pending_hits = []
	$Percent.text = str(int(percent)) + "%"
	var vel_add = Vector2()
	var force = Vector2()
	if hitting:
		if atk == "spe_neutral":
			vel_add += spe_neutral_vel()
			force += spe_neutral_acc()
		elif atk == "spe_side":
			vel_add += spe_side_vel()
			force += spe_side_acc()
		elif atk == "spe_up":
			vel_add += spe_up_vel()
			force += spe_up_acc()
		elif atk == "spe_down":
			vel_add += spe_down_vel()
			force += spe_down_acc()
	if not on_ground and is_on_floor():
		land()
	on_ground = is_on_floor()
	if on_ground and abs(velocity.x) <= 10:
		velocity.x = 0
	siding = false
	var last_vel = velocity
	var vel_walk = Vector2()
	var vel_air = Vector2()
	if not on_ground and not ledging:
		force.y += gravity
		force -= air_frott_lin*velocity
	var direction_new = 0
	if Input.is_action_pressed(ui_right):
		siding = true
		direction_new = 1
		vel_walk.x += walk_speed
		vel_air.x += air_speed
		if not on_ground and not ledging:
			force.x += air_acc/max(1, velocity.length()/200)
	if Input.is_action_pressed(ui_left):
		siding = true
		vel_walk.x -= walk_speed
		direction_new = -1
		vel_air.x -= air_speed
		if not on_ground and not ledging:
			force.x -= air_acc/max(1, velocity.length()/200)
	if on_ground:
		force.x -= ground_frott_quad*velocity.x*abs(velocity.x)
		if velocity.x != 0:
			force.x -= ground_frott_stat*velocity.x/abs(velocity.x)
	var prev_velx = velocity.x
	velocity += force*delta
	if on_ground and velocity.x * prev_velx < 0:
		velocity.x = 0
	if not hitting and stunned <= 0:
		if on_ground:
			vel_add += vel_walk
		else:
			vel_add += vel_air
	if abs(vel_add.x) > 0:
		direction_new = vel_add.x/abs(vel_add.x)
	if direction * direction_new == -1 and not ledging:
		if not hitting:
			direction = direction_new
			sprite.scale.x = 3*direction
		else:
			if not attacks[atk].locking:
				change_direction(direction_new)
	if ledging:
		vel_add.x = direction*min(direction*vel_add.x, 0)
		if vel_add.length() > 0:
			unledge()
	if not jumping and not hitting and stunned <= 0 and not ledging:
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
	last_position = position
	velocity = move_and_slide_with_snap((velocity + last_vel)/2.0 + vel_add, snap, Vector2(0, -1))
	if abs(velocity.x) >= abs(vel_add.x):
		velocity.x -= vel_add.x
	if abs(velocity.y) >= abs(vel_add.y):
		velocity.y -= vel_add.y
	if velocity.length() >= 450 and velocity.y >= 0 and (last_vel.length() < 450 or last_vel.y < 0):
		play_sound("oskour")
	if (velocity.length() < 450 or velocity.y < 0) and playing_sound[0] == "oskour":
		sounds[playing_sound[0]][playing_sound[1]].stop()
		playing_sound = [""]
	if allowed_to_ledge:
		var collision
		for i in get_slide_count():
			collision = get_slide_collision(i)
			if collision.normal.y == 0 and not on_ground and collision.collider.has_method("is_platform") and position.y - hitBox.shape.radius - hitBox.shape.height/2 >= collision.collider.position.y - collision.collider.box.shape.extents.y:
				land()
				end_hit()
				ledging = true
				change_direction(-collision.normal.x)
				play("ledge")
				velocity = Vector2.ZERO
				position.x = collision.collider.position.x + collision.normal.x*(ledgeShift.x + collision.collider.box.shape.extents.x)
				position.y = collision.collider.position.y - collision.collider.box.shape.extents.y + ledgeShift.y
				allowed_to_ledge = false
	# TEMP
	if position.y > 1000:
		position = Vector2(0, 0)
		end_hit()
