extends Area

var source
var bodies_to_exclude = []
export var damage = 5

func set_damage(_damage: int):
	damage = _damage

func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude

func fire():
	for body in get_overlapping_bodies():
		if body.has_method("hurt_fire") and !body in bodies_to_exclude:
			body.hurt_fire(damage, global_transform.origin.direction_to(body.global_transform.origin), source)
		if body.is_in_group("barrel"):
			body.hurt(20, Vector3.ZERO, source)


func setSource(_source):
	source = _source
	
