class_name RunState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "run"

func enter_state() -> void:
	var anim_name = get_name()
	var anim_data := Mobile.get_facing_as_string(owner.facing)
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})

	var anim_p = owner.get_anim_player()
	anim_p.play(current_anim)

func exit_state() -> void:
	owner.on_footstep_keyframe() # step when transitioning

func update(delta) -> void:
	if owner.dir.length() == 0:
		var new_state = owner.states.idle.new(owner)
		owner.fsm.travel_to(new_state)
		return

	var facing := Mobile.get_facing_as_string(owner.facing)
	owner.get_anim_player().play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.vel += owner.speed * owner.dir
	owner.vel = owner.move_and_slide(owner.vel)
	owner.vel = owner.vel.clamped(owner.speed)
