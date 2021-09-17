extends Node
var playerAlive = true

#func _ready():
#	connect("dead", self, "set_state_dead")
	
func player_dead():
	playerAlive = false
	print("YEW")
