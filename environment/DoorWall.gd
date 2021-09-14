extends Spatial

var can_open = true
var can_close = true
var crusher_active = false


onready var animPlayer = $AnimationPlayer


func interact():

	if can_open:
		open_door()
	elif can_close:
		close_door()
		
func open_door():
	animPlayer.play("DoorUp")
	set_false()
	
	
	
func close_door():
	animPlayer.play("DoorDown")
	set_false()
	


func set_can_open():
	can_open = true
	
func set_can_close():
	can_close = true

func set_false():
	can_open = false
	can_close = false
