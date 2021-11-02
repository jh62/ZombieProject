extends MeleeWeapon

func _ready():
	ANIMATIONS.idle = preload("res://assets/res/weapon/arms/sword/sword_idle.tres")
	ANIMATIONS.run = preload("res://assets/res/weapon/arms/sword/sword_run.tres")
	ANIMATIONS.shoot = preload("res://assets/res/weapon/arms/sword/sword_swing.tres")
	ANIMATIONS.hit = ANIMATIONS.run