extends KinematicBody

onready var graphics = $Graphics
onready var character_mover = $CharacterMover
onready var anim_player = $Graphics/AnimationPlayer
onready var health_manager = $HealthManager
onready var nav : Navigation = get_parent()
onready var aimer = $AimAtObject
var dir
onready var alertGrunt = $AlertGrunt
onready var bodyCollider = $BodyColliderShape
onready var footColliderRay = $FootColliderRay

enum STATES {IDLE, CHASE, ATTACK, DEAD, GIBBED}
var cur_state = STATES.IDLE
var target = null
var player = null
var path = []
var pathProcessDelay = 10
var pathProcessOffset = randi() % pathProcessDelay
var pathFound = false
var goal_pos 
var default_speed_exported
var target_pos
var forward_or_backward = 1
var infight_counter = 0
var infight_switch_target_at = 10

var our_pos
var player_pos
var dir_to_player


export var sight_angle = 45.0
export var turn_speed = 360.0
var landingSound

export var attack_angle = 5.0
export var attack_range = 3.0
export var attack_rate = 0.5
export var attack_anim_speed_mod = 0.5
var attack_timer : Timer
var can_attack = true
var dead = false
var updating_direction = true
var forwards

signal attack

func _ready():
	if is_in_group("knight"):
		landingSound = $LandingSound
	player = get_tree().get_nodes_in_group("player")[0]
	target = player
	default_speed_exported = character_mover.max_speed
	character_mover.update_drag()
	for child in $AimAtObject.get_children():
		if child.has_method("set_bodies_to_exclude"):
			child.set_bodies_to_exclude([self])
			child.setSource(self)
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	
	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("hurt", self, "hurt")
	
	health_manager.connect("dead", self, "set_state_dead")
	health_manager.connect("gibbed", self, "set_state_gibbed")
	character_mover.init(self)
	set_state_idle()

func _process(delta):
	
	match cur_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.CHASE:
			process_state_chase(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.DEAD:
			process_state_dead(delta)
		STATES.GIBBED:
			process_state_gibbed(delta)

func set_state_idle():
	cur_state = STATES.IDLE
	anim_player.play("idle_loop")
	character_mover.set_move_vec(Vector3.ZERO)

func set_state_chase():
	if alertGrunt != null and !alertGrunt.is_playing() and !pathFound:
		alertGrunt.play()
	cur_state = STATES.CHASE
	anim_player.play("walk_loop", 0.2)

func set_state_attack():
	cur_state = STATES.ATTACK

func set_state_dead():
	cur_state = STATES.DEAD

	anim_player.play("die")	
	dead = true
	add_collision_exception_with(player)
		
	character_mover.freeze()

func set_state_gibbed():
	cur_state = STATES.GIBBED
	bodyCollider.disabled = true
	footColliderRay.disabled = true
	timer_queue_free()


		
func process_state_gibbed(delta):
	pass
	
	

func process_state_idle(delta):
	if !target == null:
		if can_see_player():
			set_state_chase()


func process_state_chase(delta):
	if pathProcessOffset == 0:
		if target == null:
			target = player
		if within_dis_of_target(attack_range) and has_los_player():
			set_state_attack()
		if !is_instance_valid(target):
			target = player
		target_pos = target.global_transform.origin
		our_pos = global_transform.origin

	
	
		path = nav.get_simple_path(our_pos, target_pos)
		goal_pos = target_pos
		if path.size() > 0:
			pathFound = true
			goal_pos = path[1]


			dir = goal_pos - our_pos
			
			dir.y = 0
	if dir == null:
		dir = player.global_transform.origin - global_transform.origin
	character_mover.set_move_vec(dir)
	

	face_dir(dir, delta)

	character_mover.dir = dir
	
	pathProcessOffset += 1
	if pathProcessOffset == pathProcessDelay:
		pathProcessOffset = 0


	

func process_state_attack(delta):
	if !is_instance_valid(target):
		target = player

	dir = target.global_transform.origin - global_transform.origin
	dir.y = 0
	if is_instance_valid(target):
		if can_attack:
			if !within_dis_of_target(attack_range) or !can_see_player():
				set_state_chase()
			elif !player_within_angle(attack_angle):
				face_dir(global_transform.origin.direction_to(target.global_transform.origin), delta)
			else:
				start_attack()
	else:
		target = player

	character_mover.set_move_vec(dir  * forward_or_backward)
	face_dir(dir, delta)

		


func process_state_dead(delta):
	pass

func hurt(damage: int, dir: Vector3, source):
	if cur_state == STATES.IDLE:
		set_state_chase()
	health_manager.hurt(damage, dir, source)
	character_mover.knockback_force = -dir * 2
	

	if source != self:
		target = source
	elif source == player:
		target = player
		infight_counter = 0
	elif infight_counter >= infight_switch_target_at:
		target = source
		infight_counter = 0
	
		
		
	infight_counter += 1	

		
	


	


func start_attack():
	if !is_instance_valid(target):	
		target = player
		
	can_attack = false
	
	anim_player.play("attack", -1, attack_anim_speed_mod)
	attack_timer.start()
	aimer.aim_at_pos(target.global_transform.origin + Vector3.UP)

func emit_attack_signal():
	emit_signal("attack")

func finish_attack():
	can_attack = true
	reset_move_speed()

func can_see_player():
	return player_within_angle(sight_angle) and has_los_player()

func player_within_angle(angle: float):
	if !is_instance_valid(self):
		return false
	if !is_instance_valid(target):
		target = player
	dir_to_player = global_transform.origin.direction_to(target.global_transform.origin)
	forwards = global_transform.basis.z
	return rad2deg(forwards.angle_to(dir_to_player)) < angle 

func has_los_player():
	if !is_instance_valid(target):
		target = player
	our_pos = global_transform.origin + Vector3.UP
	player_pos = target.global_transform.origin + Vector3.UP
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(our_pos, player_pos, [], 1)
	if result:
		return false
	return true

func face_dir(dir: Vector3, delta):
	if updating_direction:
		var angle_diff = global_transform.basis.z.angle_to(dir)
		var turn_right = sign(global_transform.basis.x.dot(dir))
		if abs(angle_diff) < deg2rad(turn_speed) * delta:
			rotation.y = atan2(dir.x, dir.z)
		else:
			rotation.y += deg2rad(turn_speed) * delta * turn_right

func alert(check_los=true):
	if cur_state != STATES.IDLE:
		return
	if check_los and !has_los_player():
		return
	set_state_chase()

func within_dis_of_target(dis: float):
	if !target:
		target = player
	if !is_instance_valid(target):
		return false
	
	return global_transform.origin.distance_to(target.global_transform.origin) < attack_range
	
	
	
func keep_facing():
	updating_direction = true
	anim_player.play("backingup")
	character_mover.max_speed = 4
	forward_or_backward = - 1
	character_mover.update_drag()
	


func processDelay():
	pathProcessOffset += 1

func interact():
	print("INTERACTINg")

func stop_facing():
	updating_direction = false

func switch_to_player():
	target = player


func timer_queue_free():
	graphics.hide()
	$DestroyTimer.start()
	
func play_landing():
	landingSound.play()


func reset_move_speed():
	character_mover.max_speed = default_speed_exported
	forward_or_backward = 1
	character_mover.update_drag()
