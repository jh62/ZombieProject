class_name RunState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "run"

func enter_state() -> void:
	pass

func exit_state() -> void:
	owner.on_footstep_keyframe() # step when transitioning

func update(delta) -> void:
	if owner.dir.length() == 0:
		var new_state = owner.States.idle.new(owner)
		owner.fsm.travel_to(new_state)
		return

	owner.vel += owner.speed * owner.dir
	owner.vel = owner.move_and_slide(owner.vel)
	owner.vel = owner.vel.clamped(owner.speed)
