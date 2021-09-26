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




func get_pickup(pickup_type, ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.BLUE_KEY:
			has_blue_key = true
		Pickup.PICKUP_TYPES.YELLOW_KEY:
			has_yellow_key = true
		Pickup.PICKUP_TYPES.GREEN_KEY:
			has_green_key = true
	print(has_green_key, has_blue_key, has_yellow_key)
