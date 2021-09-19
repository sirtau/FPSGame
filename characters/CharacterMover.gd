extends Spatial

var body_to_move : KinematicBody = null

export var move_accel = 1.0
export var max_speed = 15
var drag = 0.0
export var jump_force = 15
export var gravity = 60

export var max_buffer := 20.0
var jump_buffer = max_buffer

export var max_glide_time := 1.0
var glide_time_left = max_glide_time


var dir : Vector3
var cur_move_vec : Vector3
var wall_jump_pressed = false
export var max_jumps = 2
var jumps_left = max_jumps


var pressed_jump = false
var force_forward = false
var move_vec : Vector3
var velocity : Vector3
var snap_vec : Vector3
var knockback_force = Vector3.ZERO
var knockback_multiplier = 20
var grounded : bool

export var ignore_rotation = false
var unrotatedMoveVelocity
var parental = get_parent()
signal movement_info

var frozen = false


func _ready():
	drag = float(move_accel) / max_speed
	jumps_left = max_jumps
	jump_buffer = max_buffer
	glide_time_left = max_glide_time

func init(_body_to_move: KinematicBody):
	body_to_move = _body_to_move
	

func jump():
	pressed_jump = true
	

func forward_push():
	force_forward = true


func set_move_vec(_move_vec: Vector3):
	move_vec = _move_vec.normalized()

func _process(delta):
	pass
	
	


func _physics_process(delta):
	handle_jump_buffer_decrease(delta)
	if frozen:
		return
	cur_move_vec = move_vec



	if !ignore_rotation:
		cur_move_vec = cur_move_vec.rotated(Vector3.UP, body_to_move.rotation.y)
	velocity += move_accel * cur_move_vec - velocity * Vector3(drag, 0, drag) + gravity * Vector3.DOWN * delta
	unrotatedMoveVelocity = velocity.rotated(Vector3.UP, -body_to_move.rotation.y)
	
	grounded = body_to_move.is_on_floor()
	if grounded:
		reset_jump_counter()
		velocity.y = -1

	if pressed_jump:
		if can_jump():
			reset_glide_time_left()
			velocity.y = jump_force
			snap_vec = Vector3.ZERO
			jumps_left -= 1
			
		
	else:
		snap_vec = Vector3.UP
		

	if knockback_force:
		knockback_force.y = 0
		knockback_force = knockback_force * knockback_multiplier
#		velocity  = knockback_force
##		velocity.y  = knockback_force.y
#
		
		
		
	
	if force_forward:
		velocity += cur_move_vec * 60 
	velocity = body_to_move.move_and_slide(velocity + knockback_force, Vector3.UP, true, 4, PI/4, false)
	force_forward = false
	pressed_jump = false
	wall_jump_pressed = false
	knockback_force = Vector3.ZERO
	
	emit_signal("movement_info", unrotatedMoveVelocity, grounded)

func freeze():
	frozen = true

func unfreeze():
	frozen = false
	

func can_jump():
	if jumps_left > 0:
		return true
	else:
		return false
	

func handle_jump_buffer_decrease(delta):
	if grounded:
		if jump_buffer < max_buffer:
			jump_buffer = max_buffer
	else:
		jump_buffer -= delta
		
	if jump_buffer <= 0:
		jumps_left -= 1
		
		

func reset_jump_counter():
	if jumps_left < max_jumps:
			jumps_left = max_jumps


func bounce_pad():
	if grounded:
		jump()
	velocity.y = 30
	reset_jumps_and_buffer()

func reset_jumps_and_buffer():
	jump_buffer = max_buffer
	jumps_left = max_jumps
	


func glide(delta):
	if glide_time_left < 0:
		return
	if velocity.y <= 0.01:
		velocity.y = 0
		glide_time_left -= delta
	

func reset_glide_time_left():
	glide_time_left = max_glide_time


func update_drag():
	drag = float(move_accel) / max_speed
