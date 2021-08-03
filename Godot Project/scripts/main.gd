extends Node

var DEBUG = true

enum GameState{
  lobby,
  stage
}

var mode = GameState.stage
var stage: Node

class Player:
	var connected: bool
	
	func _init(c=false):
		self.connected=c

class Controllers:
	var players: Array = []
	var joypads: Array = []
	
	func get_empty_player() -> int:
		var playerID=0
		var playerFound=false
		while !playerFound:
			if playerID==len(players):
				players.append(Player.new(true))
				playerFound=true
			else:
				if players[playerID].connected:
					playerID+=1
				else:
					playerFound=true
		return playerID


# Called when the node enters the scene tree for the first time.
func _ready():
	if DEBUG:
		print("Connected joypads: {j}".format({"j": Input.get_connected_joypads()}))
	
	# Load stage
	# TODO : player selection, stage selection
	var stage_scene = preload("res://scenes/stages/Stage 1/Stage 1.tscn")
	stage = stage_scene.instance()
	
	stage.nb_players = Input.get_connected_joypads().size()
	
	add_child(stage)
	
	if Input.connect("joy_connection_changed", self, "_on_joy_connection_changed"):
		print("")

func _on_joy_connection_changed(device: int, connected: bool):
	if DEBUG:
		print("Changed device {d}:{c}".format({"d":device, "c":connected}))
	if mode is GameState.lobby:
		if connected:
			pass
		else:
			pass
	elif mode is GameState.stage:
		if connected:
			pass
		else:
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
