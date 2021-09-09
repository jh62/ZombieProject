class_name ZombieHitState extends State

var attacker

func _init(owner, _attacker).(owner):
	attacker = _attacker

func get_name():
	return "hit"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	owner.vel *= -(attacker.knockback)

func exit_state() -> void:
	pass

func update(delta) -> void:
#	owner.vel *= -(attacker.knockback)
	owner.vel = owner.move_and_slide(owner.vel) # this prevents getting the collision report stuck on the last collider
#	owner.vel = owner.vel.clamped(owner.speed)

func _on_animation_finished(anim : String) -> void:
	owner.fsm.travel_to(owner.States.idle.new(owner))
