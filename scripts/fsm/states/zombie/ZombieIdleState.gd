class_name ZombieIdleState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "idle"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.waypoints = []
	owner.get_node("CollisionShape2D").set_deferred("disabled", false)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", false)

func update(delta) -> void:
	if owner.nav == null:
		return

	if !owner.can_move:
		return

	var target = owner.target

	if target != null || !owner.waypoints.empty():
		var new_state = owner.States.walk.new(owner)
		owner.fsm.travel_to(new_state)
		return

	if !owner.is_visible_in_viewport():
		return

	owner.vel = lerp(owner.vel, Vector2.ZERO, .5)
	owner.vel = owner.move_and_slide(owner.vel)
