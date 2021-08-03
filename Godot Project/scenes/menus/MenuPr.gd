extends MarginContainer

onready var boutJouer = get_node("HBoxContainer/VBoxContainer/HBoxContainer/Jouer")
onready var boutParam = get_node("HBoxContainer/VBoxContainer/HBoxContainer2/Parametres")
onready var boutQuit = get_node("HBoxContainer/VBoxContainer/HBoxContainer3/Quitter")


func _ready():
	boutJouer.grab_focus()



func _on_Jouer_pressed():
	get_tree().change_scene("res://scenes/menus/Lobby.tscn")


func _on_Parametres_pressed():
	print("Paramètres")



func _on_Quitter_pressed():
	get_tree().quit()


func _on_Jouer_focus_entered():
	boutJouer.size_flags_stretch_ratio = 2


func _on_Jouer_focus_exited():
	boutJouer.size_flags_stretch_ratio = 0.2


func _on_Parametres_focus_entered():
	boutParam.size_flags_stretch_ratio = 2


func _on_Parametres_focus_exited():
	boutParam.size_flags_stretch_ratio = 0.4


func _on_Quitter_focus_entered():
	boutQuit.size_flags_stretch_ratio = 2


func _on_Quitter_focus_exited():
	boutQuit.size_flags_stretch_ratio = 0.2
