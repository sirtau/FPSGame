extends Node
var playerAlive = true

var has_blue_key = false
var has_green_key = false
var has_yellow_key = false
var icarus_boots_level = 0
var shield_level = 0

signal upgrade_boots_level
signal upgrade_shield_level

func initalize_game():
	playerAlive = true
	has_blue_key = false
	has_green_key = false
	has_yellow_key = false
	icarus_boots_level = 0
	shield_level = 0
	

func player_dead():
	playerAlive = false


func restart_game():
	initalize_game()
	var projectiles = get_tree().get_nodes_in_group("projectiles")
	for projectile in projectiles:
		projectile.queue_free()
	get_tree().reload_current_scene()
	var player = get_tree().get_nodes_in_group("player")
	print(player)


func get_pickup(pickup_type, ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.BLUE_KEY:
			has_blue_key = true
		Pickup.PICKUP_TYPES.YELLOW_KEY:
			has_yellow_key = true
		Pickup.PICKUP_TYPES.GREEN_KEY:
			has_green_key = true
		Pickup.PICKUP_TYPES.ICARUS_BOOTS:
			icarus_boots_level += 1
			emit_signal("upgrade_boots_level")
		Pickup.PICKUP_TYPES.SHIELD_UPGRADE:
			shield_level += 1
			emit_signal("upgrade_shield_level")
			
			
	print(has_green_key, has_blue_key, has_yellow_key, icarus_boots_level)
