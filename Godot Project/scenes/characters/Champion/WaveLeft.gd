extends Area2D

var id
var atk_id
var speed = 500
var box
var players_hit
var parent

func _ready():
	box = $CollisionShape2D
	$WaveLeft.connect("animation_finished", self, "vanish")
	connect("body_entered", self, "hit")

func hit(enemy):
	if enemy.has_method("enemy_hit"):
		if not players_hit.has(enemy.id):
			players_hit.append(enemy.id)
			enemy.pending_hits.append({
				"knockback": Vector2(0, 200/enemy.mass*(1 + enemy.percent/100)),
				"dealer": str(id) + "." + str(atk_id),
				"percent": 10/enemy.mass
			})

func get_atk_percent():
	return 10

func vanish():
	parent.waving = false
	queue_free()

func _physics_process(delta):
	position.x -= speed*delta
