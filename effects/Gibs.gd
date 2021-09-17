extends Spatial


func _ready():
	var randomSound = randi() % 8 + 1
	var soundToPlay = "Splat" + str(randomSound)
	get_node(soundToPlay).play()
	randomize()
	hide()

func enable_gibs():
	show()
	for child in get_children():
		if child.has_method("init"):
			child.init()
		if "emitting" in child:
			child.emitting = true
