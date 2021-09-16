extends Area

onready var collider1 = $CollisionShape
onready var collider2 = $CollisionShape2
onready var collider3 = $CollisionShape3
onready var timer = $Timer

var space_state
var results
export var damage = 13
var damage_counter = 0
var hits = 0


func explode():
	$Particles.emitting = true
	$Particles2.emitting = true
	var query = PhysicsShapeQueryParameters.new()
	query.set_transform(global_transform)

	damageSphere(query, collider1, 2, space_state, results)
	damageSphere(query, collider2, 1, space_state, results)
	damageSphere(query, collider3, 1, space_state, results)
			
	
func damageSphere(query, collider, dmg_multiplier, space_state, results):
	var outputDamage = damage * dmg_multiplier
	query.set_shape(collider.shape)
	query.collision_mask = collision_mask
	space_state = get_world().get_direct_space_state()
	results = space_state.intersect_shape(query)
	for data in results:
		if data.collider.has_method("hurt"):
			data.collider.hurt(outputDamage, -global_transform.origin.direction_to(data.collider.global_transform.origin))
			damage_counter += outputDamage
			hits += 1
			print("Damage Counter: " + str(damage_counter))
			print("Hits: " + str(hits))
			timer.start()
			


func reset_damage_counter():
	damage_counter = 0
	hits = 0
