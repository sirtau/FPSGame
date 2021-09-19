extends Spatial

var can_open = true
var can_close = true
var crusher_active = false
var reset = false

onready var animPlayer = $AnimationPlayer
#		if animPlayer.current_animation_position == 0:

func _process(delta):
	if reset == true:
#		print("resetting")
		print(animPlayer.current_animation_position)
		if animPlayer.current_animation_position == 0:
#			print("Reset Position")
			
			animPlayer.playback_speed = 1
			set_can_close()
			crusher_active = false
			reset = false
			

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
	print("Can now close")
	can_close = true

func set_false():
	can_open = false
	can_close = false


func _on_Crusher_crushed_something():
	animPlayer.playback_speed = -1
	reset = true
	set_false()
