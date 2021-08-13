extends StaticBody2D

var box

func _ready():
	box = $CollisionShape2D

func is_platform():
	return true
