extends Spatial

var body_to_move : KinematicBody = null

export var move_accel = 1.0
export var max_speed = 15
var drag = 0.0
export var jump_force = 15
export var gravity = 60
export var jump_buffer := 2.0
var dir : Vector3
var cur_move_vec : Vector3
var wall_jump_pressed = false
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

func init(_body_to_move: KinematicBody):
	body_to_move = _body_to_move

func jump():
	pressed_jump = true

func forward_push():
	force_forward = true


func set_move_vec(_move_vec: Vector3):
	move_vec = _move_vec.normalized()

func _physics_process(delta):
	if !body_to_move.is_on_floor() and body_to_move.has_method("jump_timer_start"):
		pass 
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

	if (grounded and pressed_jump) or wall_jump_pressed:
		velocity.y = jump_force
		snap_vec = Vector3.ZERO
		
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
	
	
func leap():
	velocity


