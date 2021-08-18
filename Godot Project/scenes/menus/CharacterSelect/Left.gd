extends TextureRect

var timer

func press():
	set_modulate(Color(0.5,0.5,0.5,1))
	timer.start(0.1)

func unpress():
	set_modulate(Color(1,1,1,1))

func _ready():
	timer = $Timer
	timer.connect("timeout", self, "unpress")
