class_name RunState extends State

func get_name():
	return "run"

func update(owner : Mobile, delta) -> void:
	if owner.dir.length() == 0:
		var new_state : State = load("res://scripts/fsm/states/IdleState.gd").new()
		owner.fsm.travel_to(new_state)
		return

	owner.move_and_slide(owner.SPEED * owner.dir)
