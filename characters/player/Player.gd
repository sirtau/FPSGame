extends KinematicBody



var hotkeys = {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8,
	KEY_0: 9,
}

export var mouse_sens = 0.1
var move_vec = Vector3()



onready var camera = $Camera
onready var character_mover = $CharacterMover
onready var health_manager = $HealthManager
onready var weapon_manager = $Camera/WeaponManager
onready var pickup_manager = $PickupManager
onready var interactRay : RayCast = $Camera/InteractRay
onready var damageSound = $DamageSound
var is_on_floor = false

var posLastFrame = Vector3.ZERO
var dead = false
var rotateDirection = 0



func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character_mover.init(self)
	
	pickup_manager.max_player_health = health_manager.max_health
	health_manager.connect("health_changed", pickup_manager, "update_player_health")
	pickup_manager.connect("got_pickup", weapon_manager, "get_pickup")
	pickup_manager.connect("got_pickup", health_manager, "get_pickup")
	health_manager.init()
	health_manager.connect("dead", self, "kill")
	health_manager.connect("dead", GameManager, "player_dead")
	weapon_manager.init($Camera/FirePoint, [self])
	

func _process(_delta):
	if Input.is_action_just_pressed("use"):
		handle_use()
	
		

	if Input.is_action_just_pressed("exit"):
		mouse_mode_toggle()
	if Input.is_action_just_pressed("restart"):
		var projectiles = get_tree().get_nodes_in_group("projectiles")
		for projectile in projectiles:
			projectile.queue_free()
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("invert_mouse"):
		if Saved.invert_mouse == 1:
			Saved.invert_mouse = -1
		else:
			Saved.invert_mouse = 1
	
	if dead:
		return
	
	move_vec = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vec += Vector3.FORWARD
	if Input.is_action_pressed("move_backwards"):
		move_vec += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		rotateDirection = -1
		move_vec += Vector3.LEFT
	elif Input.is_action_pressed("move_right"):
		move_vec += Vector3.RIGHT
		rotateDirection = 1
	else:
		rotateDirection = 0
	
	
	character_mover.set_move_vec(move_vec)
	if Input.is_action_just_pressed("jump"):
		character_mover.jump()
		if is_on_wall():
			character_mover.wall_jump_pressed = true
	
	weapon_manager.attack(Input.is_action_just_pressed("attack"), 
		Input.is_action_pressed("attack"))


	
func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sens * event.relative.x
		camera.rotation_degrees.x += mouse_sens * event.relative.y * Saved.invert_mouse
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	if event is InputEventKey and event.pressed:
		if event.scancode in hotkeys:
			weapon_manager.switch_to_weapon_slot(hotkeys[event.scancode])
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			weapon_manager.switch_to_next_weapon()
		if event.button_index == BUTTON_WHEEL_UP:
			weapon_manager.switch_to_last_weapon()
		
func hurt(damage, dir, source):
	damageSound.play()
	health_manager.hurt(damage, dir, source)

	

func mouse_mode_toggle():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func heal(amount):
	health_manager.heal(amount)

func kill():
	dead = true
	character_mover.freeze()

func jump_timer_start():
	print("pinging!")


func _on_CharacterMover_movement_info(vel : Vector3, info):
	
	
	
#	rotation_degrees.x = vel.z
	camera.rotation_degrees.z = -vel.x * .5
	 
	
func handle_use():
	var collidingWith = interactRay.get_collider()

	if collidingWith != null:
		if collidingWith.has_method("hurt"):
			collidingWith.hurt(500, Vector3.UP, self)
		elif collidingWith.is_in_group("Doors"):
			collidingWith.interact()
	pass
	


