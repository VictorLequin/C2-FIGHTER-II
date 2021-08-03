extends Node

# Debug print
var DEBUG = true

# Childs
var child: Node


# Enums
enum GameState {lobby, stage}
enum KeyboardLayouts {wasd}
enum ControllerType {keyboard, joypad}

# Global vars
# TODO: start in a lobby stage
var gamestate = GameState.lobby

func playersLocked() -> bool:
	return gamestate == GameState.stage


class Keyboard:
	var _active: Dictionary
	
	func is_active(layout: int) -> bool:
		if _active.has(layout): return _active[layout]
		else: return false
	
	func set_active(layout: int, state: bool) -> void:
		_active[layout]=state


class AJoypad:
	var plugged: bool = false
	var active: bool = false

class Joypads:
	var _joypads: Array = []
	
	func exists(device: int) -> bool:
		return device < len(_joypads)
	
	func create(device: int) -> void:
		while !exists(device):
			_joypads.append(AJoypad.new())
	
	func is_plugged(device: int) -> bool:
		if !exists(device): return false
		return _joypads[device].plugged
	
	func is_active(device: int) -> bool:
		if is_plugged(device): return _joypads[device].active
		else: return false
	
	func plug(device: int) -> void:
		create(device)
		_joypads[device].plugged = true
		_joypads[device].active = false
	
	func unplug(device: int) -> void:
		_joypads[device].plugged = false
		_joypads[device].active = false
	
	func set_active(device: int, state: bool) -> void:
		_joypads[device].active = state

class ControllerRef:
	var active: bool = false
	var type: int
	var id: int
	
	func _init(a: bool = false, t: int = 0, i: int = 0):
		active = a
		type = t
		id = i

class APlayer:
	var controller: ControllerRef

class Players:
	var _players: Array
	
	func exists(playerID: int) -> bool:
		return playerID < len(_players)
	
	func is_controlled(playerID: int) -> bool:
		return _players[playerID].controller.active
	
	func is_free(playerID: int) -> bool:
		return !is_controlled(playerID)
	
	func create_player(playerID: int) -> void:
		while !exists(playerID):
			_players.append(APlayer.new())
	
	# WARNING: invalidates all greater playerIDs
	func remove_player(playerID: int) -> void:
		# TODO: notify Character
		_players.erase(playerID)
	
	func take_control(playerID: int, controller: ControllerRef) -> void:
		_players[playerID].controller = controller
	
	func free_control(controller: ControllerRef) -> int:
		for playerID in range(len(_players)):
			if (_players[playerID].controller.active) && (_players[playerID].controller.type == controller.type) && (_players[playerID].controller.id == controller.id):
				_players[playerID].controller.active = false
				return playerID
		assert(false)
		return -1
	
	func get_free_player() -> int:
		var playerID=0
		while exists(playerID):
			if is_free(playerID): return playerID
			playerID+=1
		create_player(playerID)
		return playerID
	
	func exists_free_player() -> bool:
		var playerID=0
		while exists(playerID):
			if is_free(playerID): return true
			playerID+=1
		return false
		
	func remove_free_players() -> void:
		var playerID=0
		while exists(playerID):
			if is_free(playerID): remove_player(playerID)
			else: playerID+=1
	
	func debug_list_active() -> void:
		for playerID in range(len(_players)):
			if _players[playerID].controller.active:
				print("Player {x} is active".format({"x": playerID}))


var keyboard: Keyboard = Keyboard.new()
var joypads: Joypads = Joypads.new()
var players: Players = Players.new()


func joypad_plug(device: int) -> void:
	if DEBUG: print("Connected joypads: {j}".format({"j": Input.get_connected_joypads()}))
	
	if joypads.is_plugged(device):
		print("Trying to plug twice !")
		return
	
	joypads.plug(device)
	
	if players.exists_free_player():
		var playerID = players.get_free_player()
		var controller = ControllerRef.new(true, ControllerType.joypad, device)
		players.take_control(playerID, controller)
		joypads.setActive(device, true)

func joypad_unplug(device: int) -> void:
	if DEBUG: print("Connected joypads: {j}".format({"j": Input.get_connected_joypads()}))
	
	if not joypads.is_plugged(device):
		print("Trying to unplug twice !")
		return
	
	if joypads.is_active(device):
		var controller = ControllerRef.new(true, ControllerType.joypad, device)
		var playerID = players.free_control(controller)
		if !playersLocked(): players.remove_player(playerID)
	
	joypads.unplug(device)

func joypad_join(device: int) -> void:
	assert(!playersLocked())
	if not joypads.is_active(device):
		var playerID = players.get_free_player()
		var controller = ControllerRef.new(true, ControllerType.joypad, device)
		players.take_control(playerID, controller)
		joypads.set_active(device, true)

func joypad_leave(device: int) -> void:
	assert(!playersLocked())
	if joypads.is_active(device):
		var controller = ControllerRef.new(true, ControllerType.joypad, device)
		var playerID = players.free_control(controller)
		players.remove_player(playerID)
		joypads.setActive(device, false)


func keyboard_join(layout: int) -> void:
	assert(!playersLocked())
	if not keyboard.is_active(layout):
		var playerID = players.get_free_player()
		var controller = ControllerRef.new(true, ControllerType.keyboard, layout)
		players.take_control(playerID, controller)
		keyboard.set_active(layout, true)

func keyboard_leave(layout: int) -> void:
	assert(!playersLocked())
	if keyboard.is_active(layout):
		var controller = ControllerRef.new(true, ControllerType.keyboard, layout)
		var playerID = players.free_control(controller)
		players.remove_player(playerID)
		keyboard.setActive(layout, false)

func startup_plug() -> void:
	for device in Input.get_connected_joypads():
		joypad_plug(device)

func debug_join_all() -> void:
	keyboard_join(KeyboardLayouts.wasd)
	for device in Input.get_connected_joypads():
		joypad_join(device)


# Called when the node enters the scene tree for the first time.
func _ready():
	if DEBUG:
		print("Connected joypads: {j}".format({"j": Input.get_connected_joypads()}))
	
	startup_plug()
	debug_join_all()
	players.debug_list_active()
	
	add_child(preload("res://scenes/menus/Ecran titre.tscn").instance())
	
	
	if Input.connect("joy_connection_changed", self, "_on_joy_connection_changed"):
		print("")

func _on_joy_connection_changed(device: int, connected: bool):
	if DEBUG:
		print("Joypad {d} plugged: {c}".format({"d":device, "c":connected}))
	
	if connected:
		joypad_plug(device)
	else:
		joypad_unplug(device)
	players.debug_list_active()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	print(delta)
