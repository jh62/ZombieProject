class_name RunState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "run"

func update(delta) -> void:
	if owner.dir.length() == 0:
		var new_state = owner.States.idle.new(owner)
		owner.fsm.travel_to(new_state)
		return

	owner.vel += owner.speed * owner.dir
	owner.vel = owner.move_and_slide(owner.vel)
	owner.vel = owner.vel.clamped(owner.speed)
