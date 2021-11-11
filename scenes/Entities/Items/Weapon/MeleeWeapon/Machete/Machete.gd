extends MeleeWeapon

func _ready():
	ANIMATIONS.idle = preload("res://assets/res/weapon/arms/machete/machete_idle.tres")
	ANIMATIONS.run = preload("res://assets/res/weapon/arms/machete/machete_run.tres")
	ANIMATIONS.shoot = preload("res://assets/res/weapon/arms/machete/machete_swing.tres")
	ANIMATIONS.hit = ANIMATIONS.run
