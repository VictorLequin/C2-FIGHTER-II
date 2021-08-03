extends Area2D

func _collide(area):
	if area.get_parent().has_method("_land"):
		area.get_parent()._land(self)
	if area.has_method("_bump"):
		if not area.just_landed:
			area._bump(self)

func _stop_collision(area):
	if area.get_parent().has_method("_fall"):
		area.get_parent()._fall()

func _ready():
	connect("area_entered", self, "_collide")
	connect("area_exited", self, "_stop_collision")
