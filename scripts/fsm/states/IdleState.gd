class_name IdleState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "idle"

func update(delta) -> void:
	if owner.dir.length() > 0:
		var new_state := preload("res://scripts/fsm/states/RunState.gd").new(owner)
		owner.fsm.travel_to(new_state)
		return
