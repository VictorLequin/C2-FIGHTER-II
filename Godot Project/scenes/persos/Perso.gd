extends Area2D

var screen_size
var on_ground
var sprite
var velocity
export var walk_speed = 100
export var air_acc = 200
export var ground_frott_quad = 0.3
export var ground_frott_stat = 1
var direction
var last_pos

func _land(plateforme):
	var y0 = plateforme.position.y - plateforme.get_node("CollisionShape2D").shape.extents.y
	if last_pos.y < y0 and not on_ground:
		on_ground = true
		velocity.y = 0
		position.y = y0

func _fall():
	on_ground = false

func _ready():
	screen_size = get_viewport_rect().size
	on_ground = false
	sprite = $AnimatedSprite
	velocity = Vector2()
	direction = 1
	last_pos = position

func _physics_process(delta):
	last_pos = position
	var force = Vector2()
	var vel_walk = Vector2()
	if not on_ground:
		force.y += gravity
	var direction_new = 0
	if Input.is_action_pressed("ui_right"):
		direction_new = 1
		vel_walk.x += walk_speed
		if not on_ground:
			force.x += air_acc
	if Input.is_action_pressed("ui_left"):
		vel_walk.x -= walk_speed
		direction_new = -1
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
	if on_ground:
		position += vel_walk*delta
		if vel_walk.length() > 0:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		sprite.play("air")
	position += velocity*delta
	# TEMP
	if position.y > screen_size.y:
		position.y = 0
