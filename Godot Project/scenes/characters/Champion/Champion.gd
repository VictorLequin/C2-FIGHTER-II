extends "res://scenes/characters/Character.gd"

var spe_side_speed = 300
var spe_side_count
var spe_up_count
var spe_up_speed = 300
var shieldBox
var hitBox
var percentsBlocked
var maxPercentsBlocked = 30
var stunBlockedTime = 2

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
	offsets = {
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
		"spe_down_idle": Vector2(2.58, 0.226),
		"stun": Vector2(0.528, -1.744)
	}
	percentsBlocked = 0
	hitBox = $CollisionShape2D
	shieldBox = $ShieldArea/CollisionShape2D
	$ShieldArea.connect("area_entered", self, "block")

func block(area):
	var areaP = area.get_parent()
	if areaP.has_method("enemy_hit"):
		blocked.append(str(areaP.id) + "." + str(areaP.atk_id))
		percentsBlocked += areaP.get_atk_percent()
		if percentsBlocked >= maxPercentsBlocked:
			end_hit()
			stun(stunBlockedTime)

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

func spe_down_start():
	hitBox.position.y = -46.016
	hitBox.scale.y = 0.89

func end_hit():
	hitBox.position.y = -50
	hitBox.scale.y = 1
	shieldBox.set_deferred("disabled", true)
	percentsBlocked = 0
	blocked = []
	.end_hit()

func end_anim_fn():
	if atk != "spe_down":
		.end_anim_fn()
	else:
		play("spe_down_idle")
		shieldBox.position.x = abs(shieldBox.position.x)*direction
		shieldBox.set_deferred("disabled", false)

func _input(event):
	if event.is_action_released(ui_down) and atk == "spe_down" and hitting:
		end_hit()
