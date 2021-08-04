extends KinematicBody2D

var screen_size
var on_ground
var sprite
var velocity
export var walk_speed = 200
export var air_acc = 200
export var ground_frott_quad = 0.3
export var ground_frott_stat = 1
var direction
export var jump_speed = 300
var jump_count
export var air_speed = 100
export var gravity = 1300
export var offsets = {
	"idle": Vector2(-2.336, -0.65),
	"air": Vector2(-0.434, -0.65),
	"walk": Vector2(-1.489, -0.65),
	"jump": Vector2(-1.435, -1.595),
	"neutral": Vector2(2.254, -3.725)
}
var jumping
var hitting
var siding
var playing

var ui_right: String = ""
var ui_left: String = ""
var ui_jump: String = ""

func play(anim):
	if not playing == anim:
		playing = anim
		sprite.play(anim)
		sprite.offset = offsets[anim]

func animation_finished_handler():
	playing = ""
	jumping = false
	end_hit()

func _ready():
	screen_size = get_viewport_rect().size
	on_ground = false
	sprite = $AnimatedSprite
	velocity = Vector2()
	direction = 1
	jump_count = 0
	jumping = false
	hitting = false
	siding = false
	playing = ""
	sprite.connect("animation_finished", self, "animation_finished_handler")

func end_hit():
	hitting = false

func _input(event):
	if event.is_action_pressed(ui_jump) and (on_ground or jump_count > 0):
		velocity.y = -jump_speed
		if not on_ground:
			jump_count -= 1
		jumping = true
		end_hit()
		play("jump")
	if event.is_action_pressed("ui_cancel"):
		if not siding:
			hitting = true
			play("neutral")

func _physics_process(delta):
	if not on_ground and is_on_floor():
		jump_count = 1
		jumping = false
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
			force.x += air_acc
	if Input.is_action_pressed(ui_left):
		siding = true
		vel_walk.x -= walk_speed
		direction_new = -1
		vel_air.x -= air_speed
		if not on_ground:
			force.x -= air_acc
	if on_ground:
		force.x -= ground_frott_quad*velocity.x*abs(velocity.x)
		if velocity.x != 0:
			force.x -= ground_frott_stat*velocity.x/abs(velocity.x)
	var prev_velx = velocity.x
	velocity += force*delta
	if on_ground and velocity.x * prev_velx < 0:
		velocity.x = 0
	if direction * direction_new == -1:
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
	var snap = Vector2(0, 5)
	if jumping:
		snap = Vector2.ZERO
	velocity = move_and_slide_with_snap((velocity + last_vel)/2.0 + vel_add, snap, Vector2(0, -1)) - vel_add
	# TEMP
	if position.y > screen_size.y:
		position.y = 0
	if position.x > screen_size.x + 100:
		position.x = 0
	if position.x < -1000:
		position.x = screen_size.x
