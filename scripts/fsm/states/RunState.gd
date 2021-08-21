class_name RunState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "run"

func update(delta) -> void:
	if owner.dir.length() == 0:
		var new_state : State = load("res://scripts/fsm/states/IdleState.gd").new(owner)
		owner.fsm.travel_to(new_state)
		return

	owner.move_and_slide(owner.SPEED * owner.dir)
