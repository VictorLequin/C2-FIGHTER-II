extends Control

onready var boutStage1 = $VBoxContainer/HBoxContainer/BoutStage1
onready var boutStage2 = $VBoxContainer/HBoxContainer/BoutStage2
onready var boutStage3 = $VBoxContainer/HBoxContainer/BoutStage3
onready var boutStage4 = $VBoxContainer/HBoxContainer/BoutStage4

onready var main = get_node("/root/Node")

func _ready() :
	boutStage1.grab_focus()


func _on_BoutStage1_pressed():
	get_node("/root/Node").load_stage("res://scenes/stages/Stage_1/Stage_1.tscn")


func _on_BoutStage1_focus_entered():
	boutStage1.size_flags_horizontal = boutStage1.SIZE_EXPAND_FILL


func _on_BoutStage1_focus_exited():
	boutStage1.size_flags_horizontal = boutStage1.SIZE_FILL


func _on_BoutStage2_pressed():
	print("tentative de lancement du stage 2")


func _on_BoutStage2_focus_entered():
	boutStage2.size_flags_horizontal = boutStage2.SIZE_EXPAND_FILL


func _on_BoutStage2_focus_exited():
	boutStage2.size_flags_horizontal = boutStage2.SIZE_FILL


func _on_BoutStage3_pressed():
	print("On essaye d’entrer dans le stage 3 ?")

func _on_BoutStage3_focus_entered():
	boutStage3.size_flags_horizontal = boutStage3.SIZE_EXPAND_FILL

func _on_BoutStage3_focus_exited():
	boutStage3.size_flags_horizontal = boutStage3.SIZE_FILL


func _on_BoutStage4_pressed():
	print("il n’y a pas non plus de stage 4")


func _on_BoutStage4_focus_entered():
	boutStage4.size_flags_horizontal = boutStage4.SIZE_EXPAND_FILL



func _on_BoutStage4_focus_exited():
	boutStage4.size_flags_horizontal = boutStage4.SIZE_EXPAND_FILL

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		main.load_menu("res://scenes/menus/CharacterSelect/CharacterSelect.tscn")
