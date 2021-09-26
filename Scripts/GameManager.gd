extends Node
var playerAlive = true

var has_blue_key = false
var has_green_key = false
var has_yellow_key = false

func initalize_game():
	playerAlive = true
	has_blue_key = false
	has_green_key = false
	has_yellow_key = false

func player_dead():
	playerAlive = false


func restart_game():
	
	var projectiles = get_tree().get_nodes_in_group("projectiles")
	for projectile in projectiles:
		projectile.queue_free()
	get_tree().reload_current_scene()
