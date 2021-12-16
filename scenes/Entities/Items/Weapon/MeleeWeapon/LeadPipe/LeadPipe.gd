extends MeleeWeapon

func _ready():
	ANIMATIONS.idle = preload("res://assets/res/weapon/arms/leadpipe/leadpipe_idle.tres")
	ANIMATIONS.run = preload("res://assets/res/weapon/arms/leadpipe/leadpipe_run.tres")
	ANIMATIONS.shoot = preload("res://assets/res/weapon/arms/leadpipe/leadpipe_swing.tres")
	ANIMATIONS.hit = ANIMATIONS.run

func get_weapon_type():
	return Globals.WeaponNames.LEADPIPE

func get_icon() -> Texture:
	return preload("res://assets/res/weapon/icons/leadpipe_icon.tres")
