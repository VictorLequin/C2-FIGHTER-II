extends Reference

class_name Utils

static func change_scene(current, path):
	current.queue_free()
	current.get_tree().get_root().add_child(load(path).instance(), true)

