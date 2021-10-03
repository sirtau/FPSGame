extends Area

onready var collider = $CollisionShape
onready var damageTimer = $Timer

var space_state
var results
export var damage = 15
var damage_counter = 0
var hits = 0
var crushing = false

signal crushed_something

func start_crushing():
	damageTimer.start()

func stop_crushing():
	damageTimer.stop()

func crush():
	var query = PhysicsShapeQueryParameters.new()
	query.set_transform(global_transform)
	damageSphere(query, collider, 1, space_state, results)
	
	
func damageSphere(query, collider, dmg_multiplier, space_state, results):
	var outputDamage = damage * dmg_multiplier
	query.set_shape(collider.shape)
	query.collision_mask = collision_mask
	space_state = get_world().get_direct_space_state()
	results = space_state.intersect_shape(query)
	for data in results:
		if data.collider.has_method("hurt"):
			data.collider.hurt(outputDamage, global_transform.origin.direction_to(data.collider.global_transform.origin), self)
			damage_counter += outputDamage
			hits += 1
			emit_signal("crushed_something")
#			print("Damage Counter: " + str(damage_counter))
#			print("Hits: " + str(hits))
			
			


func reset_damage_counter():
	damage_counter = 0
	hits = 0
