class_name DieState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "die"

func enter_state() -> void:
	var facing := Mobile.get_facing_as_string(owner.facing)	
	owner.get_anim_player().play("die_{1}".format({1:facing}))
	owner.hitpoints = 0
	
	if owner.equipment != null:
		owner.equipment.set_process(false)
		owner.equipment.visible = false

func update(delta) -> void:
	if owner.is_eaten:
		owner.get_node("CollisionShape2D").disabled = true
		owner.set_process(false)
		owner.set_physics_process(false)
