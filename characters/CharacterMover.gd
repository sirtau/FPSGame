extends Spatial

var body_to_move : KinematicBody = null

export var move_accel = 1.0
export var max_speed = 15
var drag = 0.0
export var jump_force = 15
export var gravity = 60

export var max_buffer := 20.0
var jump_buffer = max_buffer

export var max_glide_time := 0.0
var glide_time_left = max_glide_time


var dir : Vector3
var cur_move_vec : Vector3
var wall_jump_pressed = false
export var max_jumps = 1
var jumps_left = max_jumps
export var isPlayer = false

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
onready var parental = get_parent()
signal movement_info
signal update_jumps_left
signal glide_time_left

var frozen = false


func _ready():
	drag = float(move_accel) / max_speed
	jumps_left = max_jumps
	jump_buffer = max_buffer
	glide_time_left = max_glide_time
	emit_signal("update_jumps_left", jumps_left)
	emit_signal("glide_time_left", glide_time_left)

		

func init(_body_to_move: KinematicBody):
	body_to_move = _body_to_move
	

func jump():
	pressed_jump = true
	

func forward_push():
	force_forward = true


func set_move_vec(_move_vec: Vector3):
	move_vec = _move_vec.normalized()

func _process(delta):
	if isPlayer:
		handle_jump_buffer_decrease(delta)

	
	


func _physics_process(delta):

	if frozen:
		return
	
	cur_move_vec = move_vec

	if !ignore_rotation:
		cur_move_vec = cur_move_vec.rotated(Vector3.UP, body_to_move.rotation.y)
	velocity += move_accel * cur_move_vec - velocity * Vector3(drag, 0, drag) + gravity * Vector3.DOWN * delta
	unrotatedMoveVelocity = velocity.rotated(Vector3.UP, -body_to_move.rotation.y)
	

	grounded = body_to_move.is_on_floor()
	
	if grounded:
		velocity.y = -1
		if jumps_left < max_jumps:
			reset_jump_counter()
		if glide_time_left < max_glide_time:
			reset_glide_time_left()


	if pressed_jump:
		if can_jump():
			velocity.y = jump_force
			snap_vec = Vector3.ZERO
			jumps_left -= 1
			emit_signal("update_jumps_left", jumps_left)
			if isPlayer:
				reset_glide_time_left()
		pressed_jump = false
			
		
	else:
		snap_vec = Vector3.UP
		

	if knockback_force:
#		if !isPlayer:
		grounded = false
		knockback_force.y = .1
		knockback_force = knockback_force * knockback_multiplier
#		velocity  = knockback_force
##		velocity.y  = knockback_force.y
#
		
		
		
	
	if force_forward:
		velocity += cur_move_vec * 60 
	velocity = body_to_move.move_and_slide(velocity + knockback_force, Vector3.UP, true, 4, PI/4, false)
	force_forward = false
	
	
	knockback_force = Vector3.ZERO
	
	if isPlayer:
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
		emit_signal("update_jumps_left", jumps_left)
		
		

func reset_jump_counter():
	if jumps_left < max_jumps:
			jumps_left = max_jumps
			emit_signal("update_jumps_left", jumps_left)


func bounce_pad():
	if grounded:
		jump()
	velocity.y = 50
	if isPlayer:
		reset_jumps_and_buffer()
	else:
		reset_jumps()

func reset_jumps_and_buffer():
	jump_buffer = max_buffer
	jumps_left = max_jumps
	emit_signal("update_jumps_left", jumps_left)

func reset_jumps():
	jumps_left = max_jumps
	emit_signal("update_jumps_left", jumps_left)

func glide(delta):
	if glide_time_left < 0:
		return
	if velocity.y <= 0.01:
		velocity.y = 0
		glide_time_left -= delta
		emit_signal("glide_time_left", glide_time_left)
	

func reset_glide_time_left():
	glide_time_left = max_glide_time
	emit_signal("glide_time_left", glide_time_left)


func update_drag():
	drag = float(move_accel) / max_speed


func get_pickup(pickup_type, ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.ICARUS_BOOTS:
			upgrade_jump()

	
func upgrade_jump():
	max_jumps += 1
	max_glide_time += 1.0
	emit_signal("glide_time_left", glide_time_left)
