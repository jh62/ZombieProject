class_name ZombieRestState extends State

var elapsed := 0.0

func _init(owner).(owner):
	pass

func get_name():
	return "rest"

func enter_state(args) -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)

	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaBody/CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaPerception/CollisionShape2D").set_deferred("disabled", false)
	owner.get_node("SoftCollision/CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AttackArea/CollisionShape2D").set_deferred("disabled", true)
	
	elapsed = 0.0
	anim_p.play("die_{0}".format({0:facing}))

func update(delta) -> void:
	if owner.target == null:
		return
	if !owner.is_visible_in_viewport():
		return

	if elapsed >= 2.0:
		if owner.target is Vector2:
			owner.fsm.travel_to(owner.states.standup, null)
			return
		
		if owner.area_perception.overlaps_body(owner.target) && (!PlayerStatus.has_perk(Perk.PERK_TYPE.SHADOW_DANCER) || owner.global_position.distance_to(owner.target.global_position) < owner.sight_radius *.25):
			owner.fsm.travel_to(owner.states.standup, null)
			return

	elapsed += delta
