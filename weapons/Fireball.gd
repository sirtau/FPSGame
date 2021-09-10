extends KinematicBody
var explosion = preload("res://weapons/Explosion.tscn")

var speed = 20
var impact_damage = 10
var exploded = false
var explosion_damage = 2
func _ready():
	hide()

func set_bodies_to_exclude(bodies_to_exclude: Array):
	for body in bodies_to_exclude:
		add_collision_exception_with(body)

func _physics_process(delta):
	var collision : KinematicCollision = move_and_collide(
		-global_transform.basis.z * speed * delta)
	if collision:
		var collider = collision.collider
		if collider.has_method("hurt"):
			collider.hurt(impact_damage, -global_transform.basis.z)
		$SmokeParticles.emitting = true
		speed = 0
		explode()


func explode():
	if exploded:
		return
	exploded = true
	speed = 0
	$CollisionShape.disabled = true
	var explosion_inst = explosion.instance()
	explosion_inst.damage = explosion_damage
	get_tree().get_root().add_child(explosion_inst)
	explosion_inst.global_transform.origin = global_transform.origin
	explosion_inst.explode()
	$fireballLight.queue_free()
	$Graphics.hide()

	$DestroyAfterHitTimer.start()
