extends AspectRatioContainer

var player

func _ready():
	$Control/PortraitDePhaseLol.texture = load(player.picPath())
	var color = player.color
	color.r = 1 - (1 - color.r)*2/3
	color.g = 1 - (1 - color.g)*2/3
	color.b = 1 - (1 - color.b)*2/3
	$Control/Cadre.set_modulate(color)
