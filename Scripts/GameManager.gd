extends Node
var playerAlive = true

func initalize_game():
	playerAlive = true

func player_dead():
	playerAlive = false


func restart_game():
	var projectiles = get_tree().get_nodes_in_group("projectiles")
	for projectile in projectiles:
		projectile.queue_free()
	get_tree().reload_current_scene()
