class_name ZombieEatWaitState extends State

var corpse

func _init(owner, _corpse).(owner):
	corpse = _corpse

func get_name():
	return "eat_wait"

func enter_state() -> void:
	corpse.is_eaten = true
	var anim_p = owner.get_anim_player()
	anim_p.connect("animation_finished", self, "_on_animation_finished")

func exit_state() -> void:
	pass

func update(delta) -> void:
	owner.move_and_slide(Vector2.ZERO) # this prevents getting the collision report stuck on the last collider

func _on_animation_finished(anim : String) -> void:
	var new_state = owner.States.eat.new(owner, corpse)
	owner.fsm.travel_to(new_state)
