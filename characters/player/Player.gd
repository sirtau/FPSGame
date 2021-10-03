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


var move_vec = Vector3()
var godmode = false
var in_menu = false

export var camera_roll_multiplier := .3

onready var camera = $Camera
onready var character_mover = $CharacterMover
onready var health_manager = $HealthManager
onready var weapon_manager = $Camera/WeaponManager
onready var pickup_manager = $PickupManager
onready var interactRay : RayCast = $Camera/InteractRay
onready var damageSound = $DamageSound
onready var shieldrechargeStartTimer = $ShieldRechargeTimer
onready var shieldRecharger = $ShieldRecharger
onready var shieldEffect = $UI/ShieldEffect/AnimationPlayer
onready var escape_menu = $EscapeMenu

signal shield_enabled
signal shield_disabled
signal shield_upated

var is_on_floor = false
var collidingWith = null

var max_shield = 0.0
var cur_shield = max_shield 
var can_shield = true
var shielded = false
var shield_recharging = false

var posLastFrame = Vector3.ZERO
var dead = false
var rotateDirection = 0

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character_mover.init(self)
	
	pickup_manager.max_player_health = health_manager.max_health
	health_manager.connect("health_changed", pickup_manager, "update_player_health")
	pickup_manager.connect("got_pickup", weapon_manager, "get_pickup")
	pickup_manager.connect("got_pickup", character_mover, "get_pickup")
	pickup_manager.connect("got_pickup", health_manager, "get_pickup")
	pickup_manager.connect("got_pickup", GameManager, "get_pickup")
	pickup_manager.connect("got_pickup", self, "get_pickup")
	health_manager.init()
	health_manager.connect("dead", self, "kill")
	health_manager.connect("dead", GameManager, "player_dead")
	weapon_manager.init($Camera/FirePoint, [self])
	

func _process(_delta):
	
	collidingWith = interactRay.get_collider()
	handle_ui_hover()
	
	if Input.is_action_just_pressed("escape"):
		mouse_mode_toggle()
	
	if shielded:
		decrease_shields(_delta)
	
	weapon_manager.update_animation(move_vec, character_mover.grounded)
	
	if Input.is_action_just_pressed("use"):
		handle_use()
	if Input.is_action_just_pressed("godmode"):
		toggle_godmode()
		
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("restart"):
		GameManager.restart_game()

		
	if Input.is_action_just_pressed("invert_mouse"):
		if Saved.invert_mouse == 1:
			Saved.invert_mouse = -1
		else:
			Saved.invert_mouse = 1
	
	if dead:
		return
	
	move_vec = Vector3()
	if !in_menu:
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
		if Input.is_action_pressed("jump"):
			character_mover.glide(_delta)

		if Input.is_action_just_pressed("jump"):
			character_mover.jump()
		
		weapon_manager.attack(Input.is_action_just_pressed("attack"), 
			Input.is_action_pressed("attack"))

		if Input.is_action_just_pressed("shield"):
			if can_shield:
				shield_enabled()
		if Input.is_action_just_released("shield"):
			if can_shield:
				shield_disabled()
				shieldEffect.play("shield_off")
	
func _input(event):
	if !in_menu:
		if event is InputEventMouseMotion:
			rotation_degrees.y -= Saved.mouse_sens * event.relative.x
			camera.rotation_degrees.x += Saved.mouse_sens * event.relative.y * Saved.invert_mouse
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
	if shielded or godmode:
		return
		
	damageSound.play()
	health_manager.hurt(damage, dir, source)
	character_mover.knockback_force = -dir * damage / 4

	

func mouse_mode_toggle():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		in_menu = true
		escape_menu.show()
		
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		in_menu = false
		escape_menu.hide()

func heal(amount):
	health_manager.heal(amount)

func kill():
	dead = true
	character_mover.freeze()

func jump_timer_start():
	print("pinging!")


func _on_CharacterMover_movement_info(vel : Vector3, _info):
	camera.rotation_degrees.z = -vel.x * camera_roll_multiplier
	 
	
func handle_use():
	if collidingWith != null:
		if collidingWith.has_method("hurt"):
			collidingWith.hurt(500, Vector3.UP, self)
		elif collidingWith.is_in_group("Doors"):
			collidingWith.interact()
	pass
	


func handle_ui_hover():
	if collidingWith != null:
		if collidingWith.has_method("show_hover"):
			collidingWith.show_hover()

	


func toggle_godmode():
	if godmode == true:
		godmode = false
	else:
		godmode = true


func _on_HealthManager_gibbed():
	weapon_manager.visible = false


func shield_enabled():
	if cur_shield <= 0:
		
		if can_shield == true:
			can_shield = false
			shieldEffect.play("shield_overdrive")
		return
	if can_shield:
		if cur_shield > 0:
			if shielded == false:
				shielded = true
				shieldEffect.play("shield_on")
				shieldrechargeStartTimer.stop()
				shieldRecharger.stop()
				emit_signal("shield_enabled")
				


	
func shield_disabled():
	shielded = false
	shieldrechargeStartTimer.start()
	shieldEffect.play("shield_off")
	emit_signal("shield_disabled")


func start_recharge_shields():
	shieldRecharger.start()


func recharge_shield():
	if cur_shield < max_shield:
		cur_shield += 0.2
		
	if cur_shield >= max_shield:
		cur_shield = max_shield
		can_shield = true
		shieldRecharger.stop()
	update_shields()
	

func decrease_shields(delta):
	if cur_shield >= 0:
		cur_shield -= delta
		update_shields()
	else:
		if can_shield == true:
			can_shield = false
		shield_disabled()
		

func get_pickup(pickup_type, _ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.SHIELD_UPGRADE:
			max_shield += 1
			cur_shield = max_shield
			can_shield = true
			update_shields()

	
func update_shields():
	emit_signal("shield_upated", cur_shield)
	

func update_mouse_sens(new_sens):
	Saved.mouse_sens = new_sens


func _on_HSlider_value_changed(value):
	update_mouse_sens(value)


func _on_Level1Start_pressed():
	GameManager.start_level_1()


func _on_Level2Start_pressed():
	GameManager.start_level_2()

func _on_Level3Start_pressed():
	GameManager.start_level_3()
	
func _on_Level4Start_pressed():
	GameManager.start_level_4()
