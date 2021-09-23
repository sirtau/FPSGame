extends StaticBody

var explosion = preload("res://weapons/Explosion.tscn")

onready var explosion_sound = $ExplosionSound
onready var destroy_timer = $DestroyTimer
onready var anim_player = $AnimationPlayer
onready var barrel_mesh = $CSGMesh
onready var Hitbox = HitBox

var max_health = 20
var cur_health = 20
export var damage = 20
var exploded = false
var knockback_multiplier = 2



func hurt(damage: int, dir: Vector3, source):
	cur_health -= damage
	
	if cur_health <= 0:
		anim_player.play("damaged")


func explode():
	if exploded:
		return
	exploded = true
	explosion_sound.play()
	$CollisionShape.disabled = true
	var explosion_inst = explosion.instance()
	get_tree().get_root().add_child(explosion_inst)
	explosion_inst.global_transform.origin = global_transform.origin
	explosion_inst.damage = damage
	explosion_inst.explode()
	barrel_mesh.hide()
	destroy_timer.start()



