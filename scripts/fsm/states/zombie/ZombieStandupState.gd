class_name ZombieStandUpState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "standup"

func enter_state() -> void:	
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := "s" if owner.facing.y > 0 else "n"
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	anim_p.connect("animation_finished", self, "_on_animation_finished")

func exit_state() -> void:
	owner.hitpoints = owner.max_hitpoints

func update(delta) -> void:
	owner.vel = owner.move_and_slide(Vector2.ZERO)

func _on_animation_finished(anim : String) -> void:
	yield(owner.get_tree().create_timer(0.25),"timeout")
	var new_state = owner.States.idle.new(owner)
	owner.fsm.travel_to(new_state)
