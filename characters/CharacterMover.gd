extends Spatial

var body_to_move : KinematicBody = null

export var move_accel = 1.0
export var max_speed = 15
var drag = 0.0
export var jump_force = 15
export var gravity = 60
export var jump_buffer := 2.0

var pressed_jump = false
var force_forward = false
var move_vec : Vector3
var velocity : Vector3
var snap_vec : Vector3
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
		pass #is not on floor and jump timer? Why a jump timer again?
	if frozen:
		return
	var cur_move_vec = move_vec



	if !ignore_rotation:
		cur_move_vec = cur_move_vec.rotated(Vector3.UP, body_to_move.rotation.y)
	velocity += move_accel * cur_move_vec - velocity * Vector3(drag, 0, drag) + gravity * Vector3.DOWN * delta
	unrotatedMoveVelocity = velocity.rotated(Vector3.UP, -body_to_move.rotation.y)
	
	var grounded = body_to_move.is_on_floor()
	if grounded:
		velocity.y = -0.001

	if grounded and pressed_jump:
		velocity.y = jump_force
		snap_vec = Vector3.ZERO
	else:
		snap_vec = Vector3.UP
	
	
	if force_forward:
		velocity -= Vector3.FORWARD * 60
	velocity = body_to_move.move_and_slide_with_snap(velocity, snap_vec, Vector3.UP)
	force_forward = false
	pressed_jump = false
	
	
	emit_signal("movement_info", unrotatedMoveVelocity, grounded)

func freeze():
	frozen = true

func unfreeze():
	frozen = false
	
	
func leap():
	velocity

