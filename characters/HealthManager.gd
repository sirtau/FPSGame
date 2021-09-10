extends Spatial

var blood_spray = preload("res://effects/BloodSpray.tscn")
var gibs = preload("res://effects/Gibs.tscn")
var gibs_spawned = false
signal dead
signal hurt
signal healed
signal health_changed
signal gibbed

export var max_health = 100
var cur_health = 1

export var gib_at = -30

func _ready():
	init()

func init():
	cur_health = max_health
	emit_signal("health_changed", cur_health)

func hurt(damage: int, dir: Vector3):
	cur_health -= damage
	if cur_health <= gib_at and !gibs_spawned:
		gibs_spawned = true
		spawn_gibs()
		
		emit_signal("gibbed")
	if cur_health <= 0:
		emit_signal("dead")
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



func spawn_gibs():
	var gibs_inst = gibs.instance()
	get_tree().get_root().add_child(gibs_inst)
	gibs_inst.global_transform.origin = global_transform.origin
	gibs_inst.enable_gibs()

func get_pickup(pickup_type, ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.HEALTH:
			heal(ammo)
