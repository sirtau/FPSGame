extends Label

var ammo = 0
var health = 0

enum UI_TYPES {
	HP,
	AMMO, 
	CUR_WEAP, 
	KEYS
	}
	
var cur_ui_type = null

export(UI_TYPES) var ui_type

func _init():
	cur_ui_type = ui_type

func update_ammo(amnt):
	ammo = amnt
	update_display()

func update_health(amnt):
	health = amnt
	update_display()

func update_display():
	if cur_ui_type == UI_TYPES.HP:
		
		text = str(health)
	elif cur_ui_type == UI_TYPES.AAMO:
		var ammo_amnt = str(ammo)
		if ammo < 0:
			ammo_amnt = ""
		text += "     " + ammo_amnt
