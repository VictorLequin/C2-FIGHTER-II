extends Area2D

var id
var atk_id
var box
var players_hit
var parent
var flip

func _ready():
	flip = 1
	box = $CollisionShape2D
	connect("body_entered", self, "hit")
	parent = get_parent()

func hit(enemy):
	if enemy.has_method("enemy_hit"):
		if not players_hit.has(enemy.id):
			players_hit.append(enemy.id)
			var kb = Vector2(parent.direction*500/enemy.mass*(1 + enemy.percent/100)*flip, -100/enemy.mass*(1 + enemy.percent/100))
			if parent.atk == "spe_neutral":
				kb = -enemy.velocity
			enemy.pending_hits.append({
				"knockback": kb,
				"dealer": str(id) + "." + str(atk_id),
				"percent": get_atk_percent()/enemy.mass
			})

func get_atk_percent():
	return parent.get_atk_percent_parent()

func vanish():
	box.set_deferred("disabled", true)
	position.x = 28.25
	position.y = -42.25
	players_hit = [id]
	flip = 1
	scale.x = 1
	scale.y = 1
