extends StaticBody2D

var playing
var sprite
var real

func _ready():
	playing = ""
	real = "true"
	sprite = $AnimatedSprite
	sprite.connect("animation_finished", self, "end_anim")

func play(anim):
	sprite.play(anim)
	playing = anim

func end_anim():
	if playing == "close":
		queue_free()
