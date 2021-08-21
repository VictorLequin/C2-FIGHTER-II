extends Node2D

var characters: Array = []
var ui
onready var main = get_node("/root/Node")
var portrait_scene = preload("res://scenes/stages/Portrait.tscn")

func _create_portraits():
	
	for portrait in ui.get_children():
		ui.remove_child(portrait)
		portrait.queue_free()
	
	for k in range(main.players.count()):
		var portrait = portrait_scene.instance()
		portrait.player = main.players._players[k]
		ui.add_child(portrait)

func create_portraits():
	call_deferred("_create_portraits")

func _ready():
	ui = $CanvasLayer/ARGRid
	
	var spawn = Vector2.ZERO + Vector2.LEFT * (70*(len(characters)-1)/2.0)
	
	for character in characters:
		character.position = spawn
		spawn += Vector2.RIGHT * 70
		get_child(0).add_child(character)
	
	create_portraits()
