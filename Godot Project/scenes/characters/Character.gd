extends Area2D

var screen_size
var on_ground
var sprite
var velocity
export var walk_speed = 200
export var air_acc = 200
export var ground_frott_quad = 0.3
export var ground_frott_stat = 1
var direction
var last_pos
var just_landed
var radius
var blocked_left
var blocked_right
var blocked_on
export var jump_speed = 300
var jump_count
export var air_speed = 100
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

var ui_jump: String = ""
var ui_action: String = ""
var ui_right: String = ""
var ui_left: String = ""

func _play(anim):
	sprite.play(anim)
	sprite.offset = offsets[anim]

func _land(plateforme):
	var y0 = plateforme.position.y - plateforme.get_node("CollisionShape2D").shape.extents.y
	if last_pos.y < y0 and not on_ground:
		on_ground = true
		velocity.y = 0
		velocity.x = 0
		position.y = y0
		just_landed = true
		jump_count = 1
		jumping = false

func _fall():
	on_ground = false

func _bump(plateforme):
	var x0 = plateforme.position.x - plateforme.get_node("CollisionShape2D").shape.extents.x
	var x1 = plateforme.position.x + plateforme.get_node("CollisionShape2D").shape.extents.x
	if position.x + radius > x0 and last_pos.x + radius <= x0:
		position.x = x0 - radius
		velocity.x = 0
		blocked_right = true
		blocked_on = plateforme
	if position.x - radius < x1 and last_pos.x - radius >= x1:
		position.x = x1 + radius
		velocity.x = 0
		blocked_left = true
		blocked_on = plateforme

func _unbump(plateforme):
	if blocked_on:
		if blocked_on.name == plateforme.name:
			blocked_right = false
			blocked_left = false

func _animation_finished_handler():
	jumping = false
	_end_hit()

func _ready():
	screen_size = get_viewport_rect().size
	on_ground = false
	sprite = $AnimatedSprite
	velocity = Vector2()
	direction = 1
	last_pos = position
	just_landed = true
	radius = $CollisionShape2D.shape.radius
	blocked_left = false
	blocked_right = false
	jump_count = 0
	jumping = false
	hitting = false
	siding = false
	sprite.connect("animation_finished", self, "_animation_finished_handler")

func _move(dr):
	var dx = dr.x
	var dy = dr.y
	position.y += dy
	if dx > 0:
		if not blocked_right:
			position.x += dx
		if blocked_left:
			blocked_left = false
	if dx < 0:
		if not blocked_left:
			position.x += dx
		if blocked_right:
			blocked_right = false

func _end_hit():
	hitting = false

func _input(event):
	if event.is_action_pressed(ui_jump) and (on_ground or jump_count > 0):
		velocity.y = -jump_speed
		if not on_ground:
			jump_count -= 1
		jumping = true
		_end_hit()
		_play("jump")
	if event.is_action_pressed("ui_cancel"):
		if not siding:
			hitting = true
			_play("neutral")


func _physics_process(delta):
	siding = false
	var last_vel = velocity
	if just_landed:
		just_landed = false
	last_pos = position
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
		scale.x = direction
	if not hitting:
		if on_ground:
			_move(vel_walk*delta)
		else:
			_move(vel_air*delta)
	if not jumping and not hitting:
		if on_ground:
			if vel_walk.length() > 0:
				_play("walk")
			else:
				_play("idle")
		else:
			if velocity.length() >= 350:
				_play("air")
			else:
				_play("idle")
	_move((velocity + last_vel)*delta/2)
	# TEMP
	if position.y > screen_size.y:
		position.y = 0
	if position.x > screen_size.x + 100:
		position.x = 0
	if position.x < -1000:
		position.x = screen_size.x
