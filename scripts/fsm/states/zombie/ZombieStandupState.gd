class_name ZombieStandUpState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "standup"

func enter_state(args) -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := "s" if owner.facing.y > 0 else "n"
	anim_p.connect("animation_finished", self, "_on_animation_finished")	
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

func exit_state() -> void:
	.exit_state()
	owner.hitpoints = owner.max_hitpoints

func update(delta) -> void:
	owner.vel = owner.move_and_slide(Vector2.ZERO)

func _on_animation_finished(anim : String) -> void:
	yield(owner.get_tree().create_timer(0.25),"timeout")
	
	if is_instance_valid(owner):
		owner.get_node("CollisionShape2D").set_deferred("disabled", false)
		owner.get_node("AreaBody/CollisionShape2D").set_deferred("disabled", false)
		owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", false)
		owner.get_node("AreaPerception/CollisionShape2D").set_deferred("disabled", false)
		owner.get_node("SoftCollision/CollisionShape2D").set_deferred("disabled", false)
		owner.get_node("AttackArea/CollisionShape2D").set_deferred("disabled", false)	
		owner.fsm.travel_to(owner.states.idle, null)
