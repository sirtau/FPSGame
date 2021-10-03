extends ProgressBar

func _on_CharacterMover_glide_time_left(glide_time_left):
	if glide_time_left < 0:
		glide_time_left = 0
	value = glide_time_left
