class_name ZombieEatWaitState extends State

var corpse

func _init(owner, _corpse).(owner):
	corpse = _corpse

func get_name():
	return "eat_wait"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := "s" if owner.facing.y > 0 else "n"
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	anim_p.connect("animation_finished", self, "_on_animation_finished")

func update(delta) -> void:
	owner.vel = owner.move_and_slide(Vector2.ZERO) # this prevents getting the collision report stuck on the last collider

func _on_animation_finished(anim : String) -> void:
	yield(owner.get_tree().create_timer(.5),"timeout")
	if is_instance_valid(owner):
		var new_state = owner.states.eat.new(owner, corpse)
		owner.fsm.travel_to(new_state)
