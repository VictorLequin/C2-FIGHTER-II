extends KinematicBody2D

enum STATE {IDLE, JUMPING, HITTING, LEDGING, ROLLING, STUNNED}

var screen_size
var on_ground
var sprite
var velocity
var last_vel
var walk_speed = 200.0
var air_acc = 100.0
var air_frott_lin = 0.5
var direction
var jump_speed = 350.0
var jump_count
var air_speed = 170.0
var gravity = 750.0
var mass = 1.4
var ground_lin_frott = 3.0
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
	"ledge": Vector2(0.609, -3.412),
	"down": Vector2(4.616, 6.292),
	"roll": Vector2(30.553, -2.73)
}
var attacks = {
	"neutral": {
		"knockback": Vector2(300.0, 150.0),
		"cancelable": true,
		"locking": true, # peut-on tourner pdt l'attaque ?
		"percent": 6
	},
	"side": {
		"knockback": Vector2(450.0, 150.0),
		"cancelable": false,
		"locking": true,
		"percent": 6
	},
	"up": {
		"knockback": Vector2(0.0, 250.0),
		"cancelable": true,
		"locking": false,
		"percent": 6
	},
	"down": {
		"knockback": Vector2(0.0, -200.0),
		"cancelable": false,
		"locking": false,
		"percent": 5
	},
	"spe_neutral": {
		"cancelable": false,
		"locking": false
	},
	"spe_side": {
		"knockback": Vector2(350.0, 100.0),
		"cancelable": false,
		"locking": true,
		"percent": 9
	},
	"spe_up": {
		"knockback": Vector2(0.0, 150.0),
		"cancelable": true,
		"locking": false,
		"percent": 9
	},
	"spe_down": {
		"cancelable": true,
		"locking": true
	}
}
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
var red_highlight_time
var last_position
var damageArea
var hitBox
var ledgeShift = Vector2(26.3, 101.8)
var allowed_to_ledge
var ledgeTimer
var sounds = {}
var playing_sound
var portrait
var lives
var lives_text
var percent_text
var invincible
var roll_distance
var walking
var stun_time
var state

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
		sounds[sound][i].play()
		playing_sound = [sound, i]

func end_sound():
	playing_sound = [""]

func ready_sounds():
	for s in sounds:
		for so in sounds[s]:
			so.connect("finished", self, "end_sound")

func animation_finished_handler():
	end_anim = true

func die():
	percent = 0
	percent_text.text = "0%"
	lives -= 1
	lives_text.text = str(lives) + " vies" if lives != 1 and lives != 0 else str(lives) + " vie"
	if lives <= 0:
		portrait.get_node("Control/PortraitDePhaseLol").set_modulate(Color(0.1, 0.1, 0.1))
		get_node("/root/Node").kill_player(id)
		queue_free()

func _ready():
	screen_size = get_viewport_rect().size
	state = STATE.IDLE
	walking = false
	roll_distance = 200
	invincible = false
	lives = 3
	allowed_to_ledge = true
	playing_sound = [""]
	on_ground = false
	sprite = $AnimatedSprite
	dmgBox = $DamageArea/CollisionShape2D
	hitBox = $CollisionShape2D
	velocity = Vector2()
	last_vel = Vector2()
	direction = 1
	jump_count = 0
	siding = false
	holding_up = false
	holding_down = false
	end_anim = false
	stun_time = 0
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

func update_color(r):
	var color = portrait.player.color
	color.r = r + 1 - (1 - color.r)*2/3
	color.g = 1 - (1 - color.g)*2/3
	color.b = 1 - (1 - color.b)*2/3
	color.v *= 1.1
	sprite.set_modulate(color)

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
				"knockback": Vector2(attacks[atk].knockback.x*direction/enemy.mass*(1 + enemy.percent/100.0), -attacks[atk].knockback.y/enemy.mass*(1 + enemy.percent/100)),
				"dealer": str(damageArea.id) + "." + str(damageArea.atk_id),
				"percent": attacks[atk].percent/enemy.mass
			})
			play_sound("tiens")

func end_hit():
	if state == STATE.HITTING:
		state = STATE.IDLE
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

func roll():
	invincible = true
	state = STATE.ROLLING
	atk_time = 0
	play("roll")
	play_sound("jump")

func _input(event):
	if event.is_action_pressed(ui_jump) and (on_ground or jump_count > 0):
		var allowed_to_jump = state != STATE.HITTING and state != STATE.ROLLING and state != STATE.STUNNED
		if state == STATE.HITTING:
			if attacks[atk].cancelable:
				allowed_to_jump = true
		if allowed_to_jump:
			velocity.y = -jump_speed
			if not on_ground and state != STATE.LEDGING:
				jump_count -= 1
			if state == STATE.LEDGING:
				unledge()
				if (Input.is_action_pressed(ui_right) and direction == 1) or (Input.is_action_pressed(ui_left) and direction == -1):
					roll()
					return
			end_hit()
			state = STATE.JUMPING
			play("jump")
			play_sound("jump")
	if event.is_action_pressed(ui_action):
		var wanted_atk
		if holding_up:
			wanted_atk = "up"
		elif holding_down:
			wanted_atk = "down"
		else:
			if not siding:
				wanted_atk = "neutral"
			else:
				wanted_atk = "side"
		var allowed_to_hit = state != STATE.HITTING and state != STATE.ROLLING
		if state == STATE.HITTING and wanted_atk != atk:
			if attacks[atk].cancelable:
				allowed_to_hit = true
		if allowed_to_hit and state != STATE.STUNNED:
			if state == STATE.LEDGING:
				unledge()
			atk_id += 1
			damageArea.atk_id += 1
			if state == STATE.HITTING:
				end_hit()
			state = STATE.HITTING
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
		var allowed_to_hit = state != STATE.HITTING and state != STATE.ROLLING
		if state == STATE.HITTING and wanted_atk != atk:
			if attacks[atk].cancelable:
				allowed_to_hit = true
		if allowed_to_hit and state != STATE.STUNNED:
			if state == STATE.LEDGING:
				unledge()
			atk_id += 1
			damageArea.atk_id += 1
			if state == STATE.HITTING:
				end_hit()
			state = STATE.HITTING
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
	if state == STATE.HITTING:
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
		if atk == "down":
			var f = cst_cst_interpol(5.0/13.0, 7.5/13.0, atk_time)
			dmgBox.position.x = 12.978*f*direction
			dmgBox.position.y = 26.193*f
			dmgBox.scale.x = 50*f
			dmgBox.scale.y = 30*f

func land():
	jump_count = 1
	if state == STATE.JUMPING:
		state = STATE.IDLE
	velocity.x = 0
	if playing_sound[0] == "oskour":
		sounds[playing_sound[0]][playing_sound[1]].stop()
		playing_sound = [""]

func end_anim_fn():
	playing = ""
	if state == STATE.JUMPING:
		state = STATE.IDLE
	if state == STATE.ROLLING:
		state = STATE.IDLE
		atk_time = 0
		invincible = false
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
	state = STATE.STUNNED
	stun_time = time

func unledge():
	if state == STATE.LEDGING:
		state = STATE.IDLE
	ledgeTimer.start(0.5)

func take_hit():
	if state == STATE.LEDGING:
		unledge()
	velocity /= 2
	update_color(1)
	red_highlight_time = 0.1
	play_sound("ouch")

func test_collisions():
	var collision
	for i in get_slide_count():
		collision = get_slide_collision(i)
		if collision.normal.y == 0 and not on_ground and collision.collider.has_method("is_platform") and position.y - hitBox.shape.radius - hitBox.shape.height/2 >= collision.collider.position.y - collision.collider.box.shape.extents.y:
			land()
			end_hit()
			state = STATE.LEDGING
			change_direction(-collision.normal.x)
			play("ledge")
			velocity = Vector2.ZERO
			position.x = collision.collider.position.x + collision.normal.x*(ledgeShift.x + collision.collider.box.shape.extents.x)
			position.y = collision.collider.position.y - collision.collider.box.shape.extents.y + ledgeShift.y
			jump_count = 1
			allowed_to_ledge = false

func calc_vel_add():
	var vel_add = Vector2()
	if state == STATE.HITTING:
		if atk == "spe_neutral":
			vel_add += spe_neutral_vel()
		elif atk == "spe_side":
			vel_add += spe_side_vel()
		elif atk == "spe_up":
			vel_add += spe_up_vel()
		elif atk == "spe_down":
			vel_add += spe_down_vel()
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
	if state != STATE.HITTING and state != STATE.STUNNED:
		if on_ground:
			vel_add += vel_walk
		else:
			vel_add += vel_air
	if state == STATE.LEDGING:
		vel_add.x = direction*min(direction*vel_add.x, 0)
		if vel_add.length() > 0:
			unledge()
	return vel_add

func calc_force():
	var force = Vector2()
	if state == STATE.HITTING:
		if atk == "spe_neutral":
			force += spe_neutral_acc()
		elif atk == "spe_side":
			force += spe_side_acc()
		elif atk == "spe_up":
			force += spe_up_acc()
		elif atk == "spe_down":
			force += spe_down_acc()
	if not on_ground and state != STATE.LEDGING:
		force.y += gravity
		force -= air_frott_lin*velocity
		if Input.is_action_pressed(ui_right):
			force.x += air_acc/max(1, velocity.length()/200)
		if Input.is_action_pressed(ui_left):
			force.x -= air_acc/max(1, velocity.length()/200)
	if on_ground and not unsnapped and state != STATE.JUMPING:
		force.x -= ground_lin_frott*velocity.x
	return force

func _physics_process(delta):
	last_vel = velocity
	last_position = position
	
	if state == STATE.STUNNED:
		stun_time -= delta
		if stun_time <= 0:
			state = STATE.IDLE
	if red_highlight_time > 0:
		red_highlight_time -= delta
		if red_highlight_time <= 0:
			update_color(0)
	
	if end_anim:
		end_anim = false
		end_anim_fn()
	
	update_dmgBox(delta)
	
	if not invincible:
		var is_hit = false
		var is_hit_up = false
		for hit in pending_hits:
			if not hit.dealer in blocked:
				is_hit = true
				if hit.knockback.y < 0:
					is_hit_up = true
		if is_hit:
			take_hit()
			if is_hit_up and on_ground:
				unsnapped = true
		for hit in pending_hits:
			if not hit.dealer in blocked:
				velocity += hit.knockback
				percent += hit.percent
	pending_hits = []
	percent_text.text = str(int(percent)) + "%"
	
	if not on_ground and is_on_floor():
		land()
	on_ground = is_on_floor()
	if on_ground and abs(velocity.x) <= 10:
		velocity.x = 0
	if on_ground and not unsnapped and state != STATE.JUMPING:
		velocity.y = 0
	
	siding = false
	var direction_new = 0
	if Input.is_action_pressed(ui_right) and state != STATE.ROLLING:
		siding = true
		direction_new = 1
	if Input.is_action_pressed(ui_left) and state != STATE.ROLLING:
		siding = true
		direction_new = -1
	var vel_add = calc_vel_add()
	if abs(vel_add.x) > 0:
		direction_new = vel_add.x/abs(vel_add.x)
	if direction * direction_new == -1 and state != STATE.LEDGING:
		if state != STATE.HITTING:
			change_direction(direction_new)
		else:
			if not attacks[atk].locking:
				change_direction(direction_new)
	
	if state != STATE.ROLLING:
		var force = calc_force()
		velocity += force*delta
				
	if state == STATE.IDLE:
		if on_ground:
			if walking:
				play("walk")
			else:
				play("idle")
		else:
			if velocity.length() >= 350:
				play("air")
			else:
				play("idle")
	
	var snap = Vector2(0, 1)
	if state == STATE.JUMPING or unsnapped:
		snap = Vector2.ZERO
	if not on_ground:
		unsnapped = false
	if state != STATE.ROLLING:
		velocity = move_and_slide_with_snap(velocity, snap, Vector2(0, -1))
		if allowed_to_ledge:
			test_collisions()
		if velocity.length() >= 350 and velocity.y >= 0 and (last_vel.length() < 350 or last_vel.y < 0):
			play_sound("oskour")
		if (velocity.length() < 350 or velocity.y < 0) and playing_sound[0] == "oskour":
			sounds[playing_sound[0]][playing_sound[1]].stop()
			playing_sound = [""]
		move_and_slide_with_snap(vel_add, snap, Vector2(0, -1))
	else:
		atk_time += delta
		velocity = Vector2(direction*(roll_distance + ledgeShift.x)*(1 + 0.875*exp(-atk_time/0.050) + 1.875*exp(-atk_time/0.25)), -ledgeShift.y*1.3298270197*(cos(5.4322*atk_time-0.719739456936)/0.21+5.173*sin(5.4322*atk_time-0.719739456936))*exp(-atk_time/0.21))
		move_and_slide_with_snap(velocity, snap, Vector2(0, -1))
		
	if allowed_to_ledge:
		test_collisions()
	
	# TEMP
	if position.y > 1000:
		position = Vector2(0, 0)
		velocity = Vector2.ZERO
		land()
		end_hit()
		die()
