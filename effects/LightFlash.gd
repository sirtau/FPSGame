extends OmniLight

export var speed_multiplier = 1.0
export var decay_speed = 50
export var initial_light_energy = 16

func _process(delta):
	if light_energy > 0:
		light_energy -= decay_speed * delta * speed_multiplier
	else:
		queue_free()
