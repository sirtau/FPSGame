extends StaticBody

onready var explosion_sound = $ExplosionSound
onready var destroy_timer = $DestroyTimer
onready var anim_player = $AnimationPlayer
onready var barrel_mesh = $CSGMesh
onready var Hitbox = HitBox
var max_health = 20
var cur_health = 20
var exploded = false
var knockback_force
var knockback_multiplier = 2
var damage_dir

func _ready():
	Hitbox.connect("hurt", self, "hurt_barrel")

func hurt(damage: int, dir: Vector3, source):
	cur_health -= damage
	knockback_force = -dir * 2
	
	damage_dir = dir
	if cur_health <= 0:
		print("YAY")
		anim_player.play("damaged")
		
	
		
		
		
		


var explosion = preload("res://weapons/Explosion.tscn")


func explode():
	if exploded:
		return
	exploded = true
	explosion_sound.play()
	$CollisionShape.disabled = true
	var explosion_inst = explosion.instance()
	get_tree().get_root().add_child(explosion_inst)
	explosion_inst.global_transform.origin = global_transform.origin
	explosion_inst.explode()
	explosion_inst.damage = 10
	barrel_mesh.hide()
	destroy_timer.start()



