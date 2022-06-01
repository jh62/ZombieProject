class_name ZombieEatWaitState extends State

var corpse

func _init(owner).(owner):
	pass

func get_name():
	return "eat_wait"

func enter_state(args) -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := "s" if owner.facing.y > 0 else "n"
		
	corpse = args.corpse
	
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	anim_p.queue("{0}_{1}".format({0:get_name(),1:facing}))

func update(delta) -> void:
	owner.vel = owner.move_and_slide(Vector2.ZERO) # this prevents getting the collision report stuck on the last collider

func _on_animation_finished(anim : String) -> void:
	yield(owner.get_tree().create_timer(.5),"timeout")
	if is_instance_valid(owner):
		owner.fsm.travel_to(owner.states.eat, {
			"corpse": corpse
		})
