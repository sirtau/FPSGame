extends Area


var blood_spray = preload("res://effects/BloodSpray.tscn")

var source
var bodies_to_exclude = []
export var damage = 1

func set_damage(_damage: int):
	damage = _damage

func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude

func fire():
	for body in get_overlapping_bodies():
		if body.has_method("hurt") and !body in bodies_to_exclude:
			body.hurt(damage, global_transform.origin.direction_to(body.global_transform.origin), source)
			
			var blood_spray_inst = blood_spray.instance()
			body.add_child(blood_spray_inst)
			blood_spray_inst.global_transform.origin = body.global_transform.origin
		if body.is_in_group("projectiles"):
			body.return_to_source()


func setSource(_source):
	source = _source
	
