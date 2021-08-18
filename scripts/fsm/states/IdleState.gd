class_name IdleState extends State

func get_name():
	return "idle"

func update(owner : Mobile, delta) -> void:
	if owner.dir.length() > 0:
		var new_state := preload("res://scripts/fsm/states/RunState.gd").new()
		owner.fsm.travel_to(new_state)
		return
