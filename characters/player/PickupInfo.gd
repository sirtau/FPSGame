extends Label


const MAX_LINES = 5
var pickups_info = []

func _ready():
	text = ""

func add_pickups_info(pickup_type, amount:int):
	$RemoveInfoTimer.start()
	match pickup_type:
		Pickup.PICKUP_TYPES.CHAINGUN:
			pickups_info.push_back("Picked up Chaingun")
		Pickup.PICKUP_TYPES.CHAINGUN_AMMO:
			pickups_info.push_back("Picked up Chaingun Ammo " + str(amount))
		Pickup.PICKUP_TYPES.SHOTGUN:
			pickups_info.push_back("Picked up Shotgun")
		Pickup.PICKUP_TYPES.SHOTGUN_AMMO:
			pickups_info.push_back("Picked up Shotgun Ammo " + str(amount))
		Pickup.PICKUP_TYPES.FLAMETHROWER:
			pickups_info.push_back("Picked up Flamethrower")
		Pickup.PICKUP_TYPES.SHOTGUN_AMMO:
			pickups_info.push_back("Picked up Flamethrower Ammo " + str(amount))
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER:
			pickups_info.push_back("Picked up Rocket Launcher")
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER_AMMO:
			pickups_info.push_back("Picked up Rocket Launcher Ammo " + str(amount))
		Pickup.PICKUP_TYPES.HEALTH:
			pickups_info.push_back("Picked up Health +" + str(amount))
		Pickup.PICKUP_TYPES.BLUE_KEY:
			pickups_info.push_back("Picked up Blue Key")
		Pickup.PICKUP_TYPES.GREEN_KEY:
			pickups_info.push_back("Picked up Green Key")
		Pickup.PICKUP_TYPES.YELLOW_KEY:
			pickups_info.push_back("Picked up Yellow Key")
		Pickup.PICKUP_TYPES.SHIELD_UPGRADE:
			pickups_info.push_back("Shield Upgrade: +1 Sec")
		Pickup.PICKUP_TYPES.ICARUS_BOOTS:
			pickups_info.push_back("Pegasus Boots Upgraded.")
			pickups_info.push_back("+1 Second Glide and +1 Mid-Air Jump Added")
	while pickups_info.size() >= MAX_LINES:
		pickups_info.pop_front()
	update_display()

func remove_pickups_info():
	if pickups_info.size() > 0:
		pickups_info.pop_front()
	update_display()

func update_display():
	text = ""
	for pickups_info_text in pickups_info:
		text += pickups_info_text + "\n"


