extends Node

var DEBUG = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if DEBUG:
		print("Running {n}._ready()... connected joypads: {j}".format({
			"n":name,
			"j": Input.get_connected_joypads()
			}))
		# Report scene hierarchy.
		print("Parent of '{n}' is '{p}' (Expect 'root')".format({
			"n":name,
			"p":get_parent().name,
			}))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
