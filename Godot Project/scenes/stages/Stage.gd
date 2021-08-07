extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var characters: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var spawn = Vector2.ZERO + Vector2.LEFT * (70*(len(characters)-1)/2.0)
	
	for character in characters:
		character.position = spawn
		spawn += Vector2.RIGHT * 70
		get_child(0).add_child(character)
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
