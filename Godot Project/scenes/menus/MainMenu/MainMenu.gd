extends Control

onready var boutJouer = $VBoxContainer/HBoxContainer2/VBoxContainer/Jouer
onready var boutParam = $VBoxContainer/HBoxContainer2/VBoxContainer/Parametres
onready var boutQuit = $VBoxContainer/HBoxContainer2/VBoxContainer/Quitter

func _ready():
	boutJouer.grab_focus()


func _on_Jouer_pressed():
	#get_node("/root/Node").load_menu("res://scenes/menus/CharacterSelect/CharacterSelect.tscn")
	get_node("/root/Node").load_character_select()


func _on_Parametres_pressed():
	print("Paramètres")


func _on_Quitter_pressed():
	get_tree().quit()
