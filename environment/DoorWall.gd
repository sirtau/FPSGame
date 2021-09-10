extends Spatial

var can_open = true

onready var animPlayer = $AnimationPlayer
var stationary = true



func _on_Area_area_entered(area):
	pass # Replace with function body.


func interact():
	if can_open and stationary:
		pass
	else:
		pass
