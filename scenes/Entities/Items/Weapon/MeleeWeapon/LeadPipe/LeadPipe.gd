extends MeleeWeapon

func _ready():
	ANIMATIONS.idle = preload("res://assets/res/weapon/arms/leadpipe/leadpipe_idle.tres")
	ANIMATIONS.run = preload("res://assets/res/weapon/arms/leadpipe/leadpipe_run.tres")
	ANIMATIONS.shoot = preload("res://assets/res/weapon/arms/leadpipe/leadpipe_swing.tres")
	ANIMATIONS.hit = ANIMATIONS.run
#
#func get_idle_animations() -> Resource:
#	return preload("res://assets/res/weapon/arms/leadpipe/leadpipe_idle.tres")
#func get_run_animations() -> Resource:
#	return preload("res://assets/res/weapon/arms/leadpipe/leadpipe_run.tres")
#func get_swing_animations() -> Resource:
#	return preload("res://assets/res/weapon/arms/leadpipe/leadpipe_swing.tres")
#func get_hit_animations() -> Resource:
#	return preload("res://assets/res/weapon/arms/leadpipe/leadpipe_run.tres")
