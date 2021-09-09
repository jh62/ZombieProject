class_name ZombieIdleState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "idle"

func update(delta) -> void:
	var target = owner.target
	
	if target != null || owner.dir.length() > 0:
		var new_state = owner.States.walk.new(owner)
		owner.fsm.travel_to(new_state)
		return

	owner.vel = lerp(owner.vel, Vector2.ZERO, .5)
	owner.vel = owner.move_and_slide(owner.vel)
