class_name DieState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "die"

func enter_state() -> void:
	owner.get_node("CollisionShape2D").disabled = true
	owner.anim_p.play("die")
	owner.set_process(false)
	owner.set_physics_process(false)

func update(delta) -> void:
	pass
