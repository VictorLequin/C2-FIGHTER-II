extends Control

onready var boutStage1 = $VBoxContainer/HBoxContainer/BoutStage1
onready var boutStage2 = $VBoxContainer/HBoxContainer/BoutStage2
onready var boutStage3 = $VBoxContainer/HBoxContainer/BoutStage3
onready var boutStage4 = $VBoxContainer/HBoxContainer/BoutStage4

func _ready() :
	boutStage1.grab_focus()


func _on_BoutStage1_pressed():
	get_tree().change_scene("res://scenes/stages/Stage 1/Stage 1.tscn")


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
