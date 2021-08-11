extends Area2D

var id
var atk_id
var charac

func _ready():
	charac = get_parent()

func get_atk_percent():
	return charac.get_atk_percent_parent()
