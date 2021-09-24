extends Spatial

onready var fireParticles = $Fire
var blood_spray = preload("res://effects/BloodSpray.tscn")
var gibs = preload("res://effects/Gibs.tscn")

var gibs_spawned = false
var fire_timer

signal dead
signal hurt
signal healed
signal health_changed
signal gibbed
signal fire_tick
signal fire_ended

var alive = true
export var max_health = 200
export var starting_health = 100
var cur_health = 1
var fire_damage_per_tick = 10
var current_ticks = 0
var max_ticks = 5
var source
onready var parental = get_parent()
export var gib_at = -30



func _ready():
	init()



func init():

	cur_health = starting_health
	emit_signal("health_changed", cur_health)
	fire_timer = Timer.new()
	fire_timer.wait_time = .5
	fire_timer.one_shot = false
	fire_timer.connect("timeout", self, "take_fire_damage")
	add_child(fire_timer)

func _process(delta):
	pass

func hurt(damage: int, dir: Vector3, source):
	cur_health -= damage
	
	if cur_health <= gib_at and !gibs_spawned:
		gibs_spawned = true
		spawn_gibs()
		
		emit_signal("gibbed")
		
	if cur_health <= 0 and alive:
		
		emit_signal("dead")
		alive = false
#		if is_instance_valid(source):
#			if source.has_method("switch_to_player"):
#				source.switch_to_player()
	else:
		emit_signal("hurt")
	emit_signal("health_changed", cur_health)

func heal(amount: int):
	if cur_health <= 0:
		return
	cur_health += amount
	if cur_health > max_health:
		cur_health = max_health
	emit_signal("healed")
	emit_signal("health_changed", cur_health)

func on_fire_start(damge, _source):
	if fire_timer.is_stopped() == true:
		fire_timer.start()
	source = _source
	fireParticles.emitting = true
	fireParticles.show()

func on_fire_end():
	fire_timer.stop()
	fireParticles.emitting = false
	fireParticles.hide()
	
	emit_signal("fire_ended")
	
func take_fire_damage():
	if current_ticks == max_ticks:
		on_fire_end()
	current_ticks += 1
	hurt(fire_damage_per_tick, Vector3.ZERO, source)
	emit_signal("fire_tick")
	
		


func spawn_gibs():
	var gibs_inst = gibs.instance()
	get_tree().get_root().add_child(gibs_inst)
	gibs_inst.global_transform.origin = global_transform.origin
	gibs_inst.enable_gibs()

func get_pickup(pickup_type, ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.HEALTH:
			heal(ammo)
