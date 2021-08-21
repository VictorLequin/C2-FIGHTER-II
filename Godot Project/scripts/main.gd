extends Node

signal players_changed

# Debug print
var DEBUG = true

# Childs
var gamestate: int
var child: Node

# Enums
enum GameState {title, menu, character_select, stage}
enum KeyboardLayouts {none, wasd, arrows}
enum ControllerType {keyboard, joypad}

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
	
	func debug() -> String:
		if !active: return "Inactive"
		elif type == ControllerType.keyboard: return "Keyboard layout {x}".format({"x": id})
		elif type == ControllerType.joypad: return "Joypad {x}".format({"x": id})
		
		assert(false)
		return ""

class APlayer:
	const nbCharacters = 2
	enum CharacterIDs {champion=0, young=1}
	const characterPics = {
		CharacterIDs.champion: "res://ressources/persos/Champion/Portrait.png",
		CharacterIDs.young: "res://ressources/persos/YoungChampion/Portrait.png"
		}
	
	const characterScenes = {
		CharacterIDs.champion: preload("res://scenes/characters/Champion/Champion.tscn"),
		CharacterIDs.young: preload("res://scenes/characters/YoungChampion/YoungChampion.tscn"),
		}
	
	var controller: ControllerRef = ControllerRef.new()
	var characterID: int = CharacterIDs.champion
	
	func nextCharacter():
		characterID += 1
		if characterID >= nbCharacters: characterID = 0
	
	func prevCharacter():
		characterID -= 1
		if characterID < 0: characterID = nbCharacters-1
	
	func picPath():
		return characterPics[characterID]
	
	func instance():
		return characterScenes[characterID].instance()

class Players:
	var _players: Array
	var _lock: bool = false
	var main
	
	func _init(m):
		main = m
	
	func lock() -> void:
		_lock = true
	
	func unlock() -> void:
		_lock = false
	
	func exists(playerID: int) -> bool:
		return playerID < len(_players)
	
	func is_controlled(playerID: int) -> bool:
		return _players[playerID].controller.active
	
	func is_free(playerID: int) -> bool:
		return !is_controlled(playerID)
	
	func create_player(playerID: int) -> void:
		while !exists(playerID):
			_players.append(APlayer.new())
			set_bindings(playerID)
	
	# WARNING: invalidates all greater playerIDs
	func remove_player(playerID: int) -> void:
		_players.remove(playerID)
		set_all_bindings()
		main.emit_signal("players_changed")
	
	func take_control(playerID: int, controller: ControllerRef) -> void:
		_players[playerID].controller = controller
		set_bindings(playerID)
		main.emit_signal("players_changed")
	
	func free_control(controller: ControllerRef) -> int:
		for playerID in range(len(_players)):
			if (_players[playerID].controller.active) && (_players[playerID].controller.type == controller.type) && (_players[playerID].controller.id == controller.id):
				_players[playerID].controller.active = false
				clear_bindings(playerID)
				main.emit_signal("players_changed")
				return playerID
		assert(false)
		return -1
	
	func clear_all_bindings():
		for k in range(len(_players)):
			clear_bindings(k)
	
	func set_all_bindings():
		for k in range(len(_players)):
			set_bindings(k)
	
	func clear_bindings(playerID: int) -> void:
		if InputMap.has_action("ui_jump_{k}".format({"k": playerID})) and (len(InputMap.get_action_list("ui_jump_{k}".format({"k": playerID}))) > 0):
			InputMap.action_erase_events("ui_jump_{k}".format({"k": playerID}))
			InputMap.action_erase_events("ui_up_{k}".format({"k": playerID}))
			InputMap.action_erase_events("ui_action_{k}".format({"k": playerID}))
			InputMap.action_erase_events("ui_left_{k}".format({"k": playerID}))
			InputMap.action_erase_events("ui_right_{k}".format({"k": playerID}))
			InputMap.action_erase_events("ui_spe_{k}".format({"k": playerID}))
			InputMap.action_erase_events("ui_down_{k}".format({"k": playerID}))
	
	func set_bindings(playerID: int) -> void:
		clear_bindings(playerID)
		var controller = _players[playerID].controller
		
		if !controller.active: return
		
		var event_jump
		var event_action
		var event_left
		var event_right
		var event_up
		var event_spe
		var event_down
		
		if controller.type == ControllerType.keyboard:
			if controller.id == KeyboardLayouts.wasd:
				event_jump = InputEventKey.new()
				event_jump.scancode = KEY_SPACE
				
				event_action = InputEventKey.new()
				event_action.scancode = KEY_SHIFT
				
				event_left = InputEventKey.new()
				event_left.scancode = KEY_A
				
				event_right = InputEventKey.new()
				event_right.scancode = KEY_D
				
				event_up = InputEventKey.new()
				event_up.scancode = KEY_W
				
				event_spe = InputEventKey.new()
				event_spe.scancode = KEY_CONTROL
				
				event_down = InputEventKey.new()
				event_down.scancode = KEY_S
			
			elif controller.id == KeyboardLayouts.arrows:
				event_jump = InputEventKey.new()
				event_jump.scancode = KEY_KP_ENTER
				
				event_action = InputEventKey.new()
				event_action.scancode = KEY_KP_PERIOD
				
				event_left = InputEventKey.new()
				event_left.scancode = KEY_LEFT
				
				event_right = InputEventKey.new()
				event_right.scancode = KEY_RIGHT
				
				event_up = InputEventKey.new()
				event_up.scancode = KEY_UP
				
				event_spe = InputEventKey.new()
				event_spe.scancode = KEY_KP_0
				
				event_down = InputEventKey.new()
				event_down.scancode = KEY_DOWN
			
			else: assert(false)
		
		if controller.type == ControllerType.joypad:
			event_jump = InputEventJoypadButton.new()
			event_jump.button_index = JOY_BUTTON_0
			event_jump.device = controller.id
			
			event_action = InputEventJoypadButton.new()
			event_action.button_index = JOY_BUTTON_2
			event_action.device = controller.id
			
			event_left = InputEventJoypadMotion.new()
			event_left.device = controller.id
			event_left.axis = JOY_AXIS_0 # horizontal axis
			event_left.axis_value =  -1.0 # left
			
			event_right = InputEventJoypadMotion.new()
			event_right.device = controller.id
			event_right.axis = JOY_AXIS_0 # horizontal axis
			event_right.axis_value =  1.0 # right
			
			event_up = InputEventJoypadMotion.new()
			event_up.device = controller.id
			event_up.axis = JOY_AXIS_1
			event_up.axis_value = -1.0
			
			event_spe = InputEventJoypadButton.new()
			event_spe.device = controller.id
			event_spe.button_index = JOY_BUTTON_3
			
			event_down = InputEventJoypadMotion.new()
			event_down.device = controller.id
			event_down.axis = JOY_AXIS_1
			event_down.axis_value = 1.0
		
		if !InputMap.has_action("ui_jump_{k}".format({"k": playerID})):
			InputMap.add_action("ui_jump_{k}".format({"k": playerID}))
		InputMap.action_add_event("ui_jump_{k}".format({"k": playerID}), event_jump)
		
		if !InputMap.has_action("ui_action_{k}".format({"k": playerID})):
			InputMap.add_action("ui_action_{k}".format({"k": playerID}))
		InputMap.action_add_event("ui_action_{k}".format({"k": playerID}), event_action)
		
		if !InputMap.has_action("ui_left_{k}".format({"k": playerID})):
			InputMap.add_action("ui_left_{k}".format({"k": playerID}))
		InputMap.action_add_event("ui_left_{k}".format({"k": playerID}), event_left)
		
		if !InputMap.has_action("ui_right_{k}".format({"k": playerID})):
			InputMap.add_action("ui_right_{k}".format({"k": playerID}))
		InputMap.action_add_event("ui_right_{k}".format({"k": playerID}), event_right)
		
		if !InputMap.has_action("ui_up_{k}".format({"k": playerID})):
			InputMap.add_action("ui_up_{k}".format({"k": playerID}))
		InputMap.action_add_event("ui_up_{k}".format({"k": playerID}), event_up)
		
		if !InputMap.has_action("ui_spe_{k}".format({"k": playerID})):
			InputMap.add_action("ui_spe_{k}".format({"k": playerID}))
		InputMap.action_add_event("ui_spe_{k}".format({"k": playerID}), event_spe)
		
		if !InputMap.has_action("ui_down_{k}".format({"k": playerID})):
			InputMap.add_action("ui_down_{k}".format({"k": playerID}))
		InputMap.action_add_event("ui_down_{k}".format({"k": playerID}), event_down)
	
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
		var t = []
		for playerID in range(len(_players)):
			if _players[playerID].controller.active:
				t.append(playerID)
		print("Active players: {t}".format({"t": t}))
		
	func get_characters():
		var characters: Array = []
		
		for k in range(len(_players)):
			set_bindings(k)
			
			var character
			character = _players[k].instance()
			character.setup_id(k)
			characters.append(character)
		
		return characters
	
	func count() -> int:
		return len(_players)



var keyboard: Keyboard = Keyboard.new()
var joypads: Joypads = Joypads.new()
var players: Players = Players.new(self)


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
		joypads.set_active(device, true)

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

func joypad_join(device: int) -> bool:
	assert(!playersLocked())
	if joypads.is_active(device): return false
	
	var playerID = players.get_free_player()
	var controller = ControllerRef.new(true, ControllerType.joypad, device)
	players.take_control(playerID, controller)
	joypads.set_active(device, true)
	
	if DEBUG: players.debug_list_active()
	return true

func joypad_leave(device: int) -> bool:
	assert(!playersLocked())
	if not joypads.is_active(device): return false
	
	var controller = ControllerRef.new(true, ControllerType.joypad, device)
	var playerID = players.free_control(controller)
	players.remove_player(playerID)
	joypads.set_active(device, false)
	
	if DEBUG: players.debug_list_active()
	return true


func keyboard_join(layout: int) -> bool:
	assert(!playersLocked())
	if keyboard.is_active(layout): return false
	
	var playerID = players.get_free_player()
	var controller = ControllerRef.new(true, ControllerType.keyboard, layout)
	players.take_control(playerID, controller)
	keyboard.set_active(layout, true)
	
	if DEBUG: players.debug_list_active()
	return true

func keyboard_leave(layout: int) -> bool:
	assert(!playersLocked())
	if not keyboard.is_active(layout): return false
	
	var controller = ControllerRef.new(true, ControllerType.keyboard, layout)
	var playerID = players.free_control(controller)
	players.remove_player(playerID)
	keyboard.set_active(layout, false)
	
	if DEBUG: players.debug_list_active()
	return true

func startup_plug() -> void:
	for device in Input.get_connected_joypads():
		joypad_plug(device)

func debug_join_all() -> void:
	keyboard_join(KeyboardLayouts.wasd)
	for device in Input.get_connected_joypads():
		joypad_join(device)

func list_inactive() -> Array:
	var ret = []
	for layout in [KeyboardLayouts.wasd, KeyboardLayouts.arrows]:
		if not keyboard.is_active(layout): ret.append(ControllerRef.new(true, ControllerType.keyboard, layout))
	for device in Input.get_connected_joypads():
		if not joypads.is_active(device): ret.append(ControllerRef.new(true, ControllerType.joypad, device))
	return ret

# Called when the node enters the scene tree for the first time.
func _ready():
	if DEBUG:
		print("Connected joypads: {j}".format({"j": Input.get_connected_joypads()}))
	
	change_child(load("res://scenes/menus/TitleScreen/TitleScreen.tscn").instance(), false)
	#add_child(load("res://scenes/menus/TitleScreen/TitleScreen.tscn").instance())
	
	gamestate = GameState.title
	
	startup_plug()
	#debug_join_all()
	#players.debug_list_active()
	
	
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")


func _on_joy_connection_changed(device: int, connected: bool):
	if DEBUG:
		print("Joypad {d} plugged: {c}".format({"d":device, "c":connected}))
	
	if connected:
		joypad_plug(device)
	else:
		joypad_unplug(device)
	players.debug_list_active()


func load_menu(path):
	gamestate = GameState.menu
	players.unlock()
	change_child(load(path).instance(), true)

func load_character_select():
	gamestate = GameState.character_select
	load_menu("res://scenes/menus/CharacterSelect/CharacterSelect.tscn")
	connect("players_changed", child, "recreate_boxes")

func load_stage(path):
	gamestate = GameState.stage
	players.lock()
	var stage = load(path).instance()
	stage.characters = players.get_characters()
	change_child(stage, true)

func change_child(c, free_old):
	if free_old: child.queue_free()
	child = c
	call_deferred("add_child", c)


func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.set_window_fullscreen(!OS.window_fullscreen)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	print(delta)
