extends BaseWeapon

func _init() -> void:
	texture_idle = preload("res://assets/res/char/arms/idle_handgun.tres")
	texture_run = preload("res://assets/res/char/arms/run_handgun.tres")
	texture_shoot = preload("res://assets/res/char/arms/shoot_handgun.tres")

func get_name():
	return "pistol"
