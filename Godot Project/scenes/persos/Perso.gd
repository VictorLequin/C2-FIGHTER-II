extends Area2D

var screen_size
var on_ground
var sprite
var velocity
export var speed = 50
var direction

func _ready():
	screen_size = get_viewport_rect().size
	on_ground = true
	sprite = $AnimatedSprite
	sprite.play("idle")
	velocity = Vector2()
	direction = 1

func _physics_process(delta):
	var force = Vector2()
	var vel_walk = Vector2()
	if not on_ground:
		force.y += gravity
	velocity += force*delta
	var direction_new = 0
	if Input.is_action_pressed("ui_right"):
		direction_new = 1
		vel_walk.x += speed
	if Input.is_action_pressed("ui_left"):
		vel_walk.x -= speed
		direction_new = -1
	if direction * direction_new == -1:
		direction = direction_new
		scale.x = direction
	if vel_walk.length() > 0:
		sprite.play("walk")
	elif on_ground:
		sprite.play("idle")
	position += velocity*delta
	position += vel_walk*delta
