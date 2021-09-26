extends KinematicBody
var explosion = preload("res://weapons/Explosion.tscn")

onready var fireballHitSound = $FireballHit
var source
var speed = 10
var selfbodies = []
var impact_damage = 10
var exploded = false
var explosion_damage = 5
var direction = 1

func _ready():
	hide()

func set_bodies_to_exclude(bodies_to_exclude: Array):
	for body in bodies_to_exclude:
		add_collision_exception_with(body)

func remove_exclusions(selfbodies):
	for body in selfbodies:
		remove_collision_exception_with(body)

func _physics_process(delta):
	var collision : KinematicCollision = move_and_collide(
		-global_transform.basis.z * speed * delta * direction)
	if collision:
		var collider = collision.collider
		if collider.has_method("shield_enabled"):
			if collider.shielded:
				direction = -direction
				remove_exclusions(selfbodies)
				
				
				return
		if collider.has_method("hurt"):
			collider.hurt(impact_damage, -global_transform.basis.z, source)

		$SmokeParticles.emitting = true
		speed = 0
		explode()


func explode():
	if exploded:
		return
	
	
	fireballHitSound.play()
	exploded = true
	speed = 0
	$CollisionShape.disabled = true
	var explosion_inst = explosion.instance()
	explosion_inst.damage = explosion_damage
	get_tree().get_root().add_child(explosion_inst)
	explosion_inst.global_transform.origin = global_transform.origin
	if source == null:
		print("ERROR NULL FK")
	explosion_inst.source = source
	explosion_inst.explode()
	
	$fireballLight.queue_free()
	$Graphics.hide()

	$DestroyAfterHitTimer.start()
