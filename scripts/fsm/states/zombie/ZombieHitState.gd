class_name ZombieHitState extends State

var attacker

func _init(owner, _attacker).(owner):
	attacker = _attacker

func get_name():
	return "hit"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))	
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)
	owner.vel *= -(attacker.knockback)

func exit_state() -> void:
	pass

func update(delta) -> void:
	owner.vel = owner.move_and_slide(owner.vel) # this prevents getting the collision report stuck on the last collider

func _on_animation_finished(anim : String) -> void:
	owner.fsm.travel_to(owner.States.idle.new(owner))
