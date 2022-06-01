class_name IdleState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "idle"

func enter_state(args) -> void:
	var anim_name = get_name()
	var anim_data := Mobile.get_facing_as_string(owner.facing)
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})

	var anim_p = owner.get_anim_player()
	anim_p.play(current_anim)

func update(delta) -> void:
	if owner.dir.length() > 0:
		owner.fsm.travel_to(owner.states.run, null)
		return

	var facing := Mobile.get_facing_as_string(owner.facing)
	owner.get_anim_player().play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.vel = lerp(owner.vel, Vector2.ZERO, .25)
	owner.vel = owner.move_and_slide(owner.vel)
