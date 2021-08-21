extends Control

var select_box_scene = preload("res://scenes/menus/CharacterSelect/SelectBox.tscn")

onready var main = get_node("/root/Node")

func recreate_boxes():
	call_deferred("_recreate_boxes")

func _recreate_boxes():
	var grid = $ARGrid
	
	for box in grid.get_children():
		grid.remove_child(box)
		box.queue_free()
	
	var item_count = main.players.count()
	var some_inactive = !main.list_inactive().empty()
	if some_inactive: item_count += 1
	
	for k in range(main.players.count()):
		var box = select_box_scene.instance()
		box.player = main.players._players[k]
		box.ui_left = "ui_left_{k}".format({"k": k})
		box.ui_right = "ui_right_{k}".format({"k": k})
		grid.add_child(box)
	
	if some_inactive:
		grid.add_child(preload("res://scenes/menus/CharacterSelect/PressAccept.tscn").instance())

func _ready():
	recreate_boxes()

func _input(event):
	var main = get_node("/root/Node")
	
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var bounds = Rect2(rect_position, rect_size)
		if bounds.has_point(event.position):
			if main.players.count() > 0:
				main.load_menu("res://scenes/menus/StageSelect/StageSelect.tscn")
			else:
				print("Argh! No players joined!")
	
	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_0 :
		if main.joypad_join(event.device): get_tree().set_input_as_handled()
	
	elif event is InputEventKey:
		var layout = main.KeyboardLayouts.none
		if event.scancode == KEY_SPACE:
			layout = main.KeyboardLayouts.wasd
		elif event.scancode == KEY_KP_ENTER:
			layout = main.KeyboardLayouts.arrows
		
		if layout != main.KeyboardLayouts.none:
			if main.keyboard_join(layout): get_tree().set_input_as_handled()
	
	
	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_1 :
		if main.joypad_leave(event.device): get_tree().set_input_as_handled()
	
	elif event is InputEventKey:
		var layout = main.KeyboardLayouts.none
		if event.scancode == KEY_ESCAPE:
			layout = main.KeyboardLayouts.wasd
		elif event.scancode == KEY_KP_PERIOD:
			layout = main.KeyboardLayouts.arrows
		
		if layout != main.KeyboardLayouts.none:
			if main.keyboard_leave(layout): get_tree().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
