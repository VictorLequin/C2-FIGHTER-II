extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var characters: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var main = get_node("/root/Node")
	
	var spawn = get_viewport_rect().size/2 + Vector2.LEFT * (70*(len(characters)-1)/2)
	
	for character in characters:
		character.position = spawn
		spawn += Vector2.RIGHT * 70
		add_child(character)
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
