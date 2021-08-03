extends Area2D

var screen_size
var on_ground
var sprite
var velocity

func _ready():
	screen_size = get_viewport_rect().size
	on_ground = true
	sprite = $AnimatedSprite
	sprite.play("idle")
	velocity = Vector2()

func _physics_process(delta):
	var force = Vector2()
	if not on_ground:
		force.y += gravity
	velocity += force*delta
	position += velocity*delta
#    if Input.is_action_pressed("ui_right"):
#        velocity.x += 1
