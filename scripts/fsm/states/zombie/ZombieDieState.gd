class_name ZombieDieState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "die"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)	
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	
	owner.get_node("CollisionShape2D").disabled = true	
	owner.set_process(false)
	owner.set_physics_process(false)

func update(delta) -> void:
	pass
