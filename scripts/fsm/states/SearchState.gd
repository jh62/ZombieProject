class_name SearchState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "search"

func update(delta) -> void:
	if owner.dir.length() > 0:
		var new_state = owner.States.run.new(owner)
		owner.fsm.travel_to(new_state)
		return

	owner.vel = lerp(owner.vel, Vector2.ZERO, .25)
	owner.vel = owner.move_and_slide(owner.vel)
