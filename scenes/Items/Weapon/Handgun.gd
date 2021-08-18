extends BaseWeapon

func _ready() -> void:
	texture_idle = preload("res://assets/res/char/arms/idle_handgun.tres")
	texture_run = preload("res://assets/res/char/arms/run_handgun.tres")

func get_name():
	return "handgun"
