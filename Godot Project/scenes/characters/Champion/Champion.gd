extends "res://scenes/characters/Character.gd"

var spe_side_speed = 300
var spe_side_count
var spe_up_count
var spe_up_speed = 300
var shieldBox
var percentsBlocked
var maxPercentsBlocked = 30
var stunBlockedTime = 2
var waveRight
var waveLeft
var waveRightBox
var waveLeftBox
var timer
var waveLeftBody
var waveRightBody

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
		"stun": Vector2(0.528, -1.744),
		"ledge": Vector2(0.609, -3.412)
	}
	percentsBlocked = 0
	shieldBox = $ShieldArea/CollisionShape2D
	$ShieldArea.connect("area_entered", self, "block")
	waveLeft = $WaveLeftBody/WaveLeft
	waveRight = $WaveRightBody/WaveRight
	waveLeftBox = $WaveLeftBody/CollisionShape2D
	waveRightBox = $WaveRightBody/CollisionShape2D
	timer = $WaveDelay
	timer.connect("timeout", self, "spe_neutral_land")
	waveLeftBody = $WaveLeftBody
	waveRightBody = $WaveRightBody
	waveLeftBody.id = id
	waveLeftBody.players_hit = [id]
	waveRightBody.id = id
	waveRightBody.players_hit = [id]

func block(area):
	if area.has_method("get_atk_percent"):
		blocked.append(str(area.id) + "." + str(area.atk_id))
		percentsBlocked += area.get_atk_percent()
		if percentsBlocked >= maxPercentsBlocked:
			end_hit()
			stun(stunBlockedTime)

func land():
	spe_side_count = 1
	spe_up_count = 1
	.land()

func spe_side_acc():
	var acc = Vector2()
	if not on_ground:
		acc.y -= gravity
	return acc

func spe_side_vel():
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

func spe_up_vel():
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

func spe_neutral_land():
	if on_ground and not waveRightBody.moving:
		atk_id += 1
		waveRightBody.visible = true
		waveRight.set_frame(0)
		waveRight.play()
		waveRightBox.set_deferred("disabled", false)
		waveRightBody.atk_id = atk_id
		waveRightBody.moving = true
		atk_id += 1
		waveLeftBody.visible = true
		waveLeft.set_frame(0)
		waveLeft.play()
		waveLeftBox.set_deferred("disabled", false)
		waveLeftBody.atk_id = atk_id
		waveLeftBody.moving = true

func spe_neutral_start():
	timer.start(0.5)

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

func _physics_process(delta):
	if waveRightBody.moving:
		waveRightBody.position += last_position-position
		waveLeftBody.position += last_position-position