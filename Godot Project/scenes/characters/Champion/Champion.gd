extends "res://scenes/characters/Character.gd"

var spe_side_speed = 300
var spe_side_count
var spe_up_count
var spe_up_speed = 300

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
		if atk == "spe_side":
			var f = lin_interpol(7.0/8.0, atk_time)
			dmgBox.position.x = 60.989*f*direction
			dmgBox.position.y = -53.003
			dmgBox.scale.x = 45.721*f
			dmgBox.scale.y = 10.567
		if atk == "spe_up":
			var f = cst_cst_interpol(1.0/10.0, 6.5/10.0, atk_time)
			dmgBox.position.x = 15.362*f*direction
			dmgBox.position.y = -77.076*f
			dmgBox.scale.x = 10*f
			dmgBox.scale.y = 39.953*f

func _ready():
	spe_side_count = 0
	spe_up_count = 0

func land():
	spe_side_count = 1
	spe_up_count = 1
	.land()

func spe_side_acc(delta):
	var acc = Vector2()
	if not on_ground:
		acc.y -= gravity
	return acc

func spe_side_vel(delta):
	return Vector2(spe_side_speed*direction, 0)

func spe_side_start():
	if on_ground:
		dmgBox.set_deferred("disabled", false)
	elif spe_side_count > 0:
		dmgBox.set_deferred("disabled", false)
		spe_side_count -= 1
		velocity.y = 0
	else:
		end_hit()

func spe_up_vel(delta):
	return Vector2(0, -spe_up_speed)

func spe_up_start():
	if spe_up_count > 0:
		velocity.y = 0
		dmgBox.set_deferred("disabled", false)
		spe_up_count -= 1
		unsnapped = true
	else:
		end_hit()
