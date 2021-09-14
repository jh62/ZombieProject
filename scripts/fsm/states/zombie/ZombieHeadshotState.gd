class_name ZombieHeadshotState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "headshot"

func enter_state() -> void:
	print_debug("HEADSHOT state")
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)	
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	
	owner.get_node("CollisionShape2D").call_deferred("queue_free")
	owner.get_node("AreaHead/CollisionShape2D").call_deferred("queue_free")
	
#	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
#	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)

func update(delta) -> void:
	pass

func _on_animation_finished(anim : String) -> void:
	owner.set_process(false)
	owner.set_physics_process(false)
