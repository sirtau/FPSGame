extends OmniLight


var decay_speed = 50


func _process(delta):
	if light_energy > 0:
		light_energy -= decay_speed * delta
	else:
		queue_free()
