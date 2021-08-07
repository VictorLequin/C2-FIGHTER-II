extends Camera2D

const margins = 200
const min_margins = 50
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
	else: return -Vector2.ONE * margins * 10

func calc_end() -> Vector2:
	var ok = false
	var new_end = -Vector2.INF
	for character in get_parent().get_child(0).get_children():
		ok = true
		new_end.x = max(new_end.x, character.position.x)
		new_end.y = max(new_end.y, character.position.y)
	if ok: return new_end
	else: return Vector2.ONE * margins * 10

# Called when the node enters the scene tree for the first time.
func _ready():
	start = calc_start() - Vector2.ONE * margins * 5
	end = calc_end() + Vector2.ONE * margins * 5
	
	print(start, end)

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
	
	var screen_size = get_viewport_rect().size
	var tmp = size/screen_size
	zoom = Vector2.ONE * max(tmp.x, tmp.y)
	position = center
