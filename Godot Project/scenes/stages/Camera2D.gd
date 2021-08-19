extends Camera2D

const initial = 1000
const margins = 400
const min_margins = margins / 2
const cam_offset = 50*Vector2.UP
const interp_speed = 2

var start
var end


func calc_start() -> Vector2:
	var ok = false
	var new_start = +Vector2.INF
	for character in get_parent().get_child(0).get_children():
		ok = true
		new_start.x = min(new_start.x, character.position.x)
		new_start.y = min(new_start.y, character.position.y)
	if ok: return new_start
	else: return -Vector2.ONE * initial

func calc_end() -> Vector2:
	var ok = false
	var new_end = -Vector2.INF
	for character in get_parent().get_child(0).get_children():
		ok = true
		new_end.x = max(new_end.x, character.position.x)
		new_end.y = max(new_end.y, character.position.y)
	if ok: return new_end
	else: return Vector2.ONE * initial

# Called when the node enters the scene tree for the first time.
func _ready():
	start = calc_start() - Vector2.ONE * margins * 5
	end = calc_end() + Vector2.ONE * margins * 5

func interpolate(a, b, delta):
	var t = delta * interp_speed
	return a*(1-t)+b*t

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_start = calc_start()
	var new_end   = calc_end()
	
	start.x = min(interpolate(start.x, new_start.x - margins, delta), new_start.x - min_margins)
	start.y = min(interpolate(start.y, new_start.y - margins, delta), new_start.y - min_margins)
	
	end.x = max(interpolate(end.x, new_end.x + margins, delta), new_end.x + min_margins)
	end.y = max(interpolate(end.y, new_end.y + margins, delta), new_end.y + min_margins)
	
	
	var center = (start+end)/2 + cam_offset
	var size = (end-start)
	
	var screen_size = OS.window_size
	print(screen_size)
	var tmp = size/screen_size
	print((screen_size.x/screen_size.y)/(16.0/9.0))
	zoom = Vector2(1, (16.0/9.0)/(screen_size.x/screen_size.y)) * max(tmp.x, tmp.y)
	position = center
