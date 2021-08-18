extends BaseWeapon

func _init() -> void:
	texture_idle = preload("res://assets/res/char/arms/idle_disarmed.tres")
	texture_run = preload("res://assets/res/char/arms/run_disarmed.tres")

func get_name():
	return "disarmed"
