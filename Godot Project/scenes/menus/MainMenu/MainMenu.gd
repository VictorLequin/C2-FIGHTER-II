extends Control

var boutJouer
var boutParam
var boutQuit

func _ready():
	boutJouer = $Jouer
	boutParam = $Quitter
	boutQuit = $Quitter
	boutJouer.grab_focus()
	boutJouer.connect("pressed", self, "_on_Jouer_pressed")
	boutParam.connect("pressed", self, "_on_Parametres_pressed")
	boutQuit.connect("pressed", self, "_on_Quitter_pressed")

func _on_Jouer_pressed():
	#get_node("/root/Node").load_menu("res://scenes/menus/CharacterSelect/CharacterSelect.tscn")
	get_node("/root/Node").load_character_select()

func _on_Parametres_pressed():
	print("Paramètres")

func _on_Quitter_pressed():
	get_tree().quit()
