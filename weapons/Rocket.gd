extends KinematicBody

var explosion = preload("res://weapons/Explosion.tscn")
onready var explodeSound = $ProjectileHitsound
var speed = 40
var impact_damage = 20
var exploded = false
var selfbodies = []
var source
var direction = 1
func _ready():
	hide()

func set_bodies_to_exclude(bodies_to_exclude: Array):
	selfbodies = bodies_to_exclude
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
				return_to_source()
				
				
				return
		if collider.has_method("hurt"):
			collider.hurt(impact_damage, -global_transform.basis.z, source)

		explode()

func explode():
	if exploded:
		return
	exploded = true
	explodeSound.play()
	speed = 0
	$CollisionShape.disabled = true
	var explosion_inst = explosion.instance()
	get_tree().get_root().add_child(explosion_inst)
	explosion_inst.global_transform.origin = global_transform.origin
	explosion_inst.explode()
	explosion_inst.setSource(source)
	$SmokeTrail.emitting = false
	$Graphics.hide()
	$OmniLight.hide()
	$DestroyAfterHitTimer.start()


func setSource(_source):
	source = _source

func return_to_source():
	direction = -direction
	remove_exclusions(selfbodies)
