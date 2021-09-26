extends Label

func _on_ammo_upated(ammo):
	text = str(ammo)



func _on_WeaponManager_ammo_changed(ammo):
	text = str(ammo)
