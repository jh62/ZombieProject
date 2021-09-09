class_name ZombieEatState extends State

var corpse : Mobile

func _init(owner, _corpse).(owner):
	corpse = _corpse

func get_name():
	return "eat"

func enter_state() -> void:	
	owner.target = null
	owner.dir = Vector2.ZERO
	
	yield(owner.get_tree().create_timer(5.0),"timeout")
	var new_state := ZombieIdleState.new(owner)
	owner.fsm.travel_to(new_state)

func exit_state() -> void:
	pass

func update(delta) -> void:
	pass
#	owner.vel += owner.global_position.direction_to(corpse.global_position)
#	owner.global_position = owner.global_position.move_toward(corpse.global_position, delta)
	#owner.move_and_slide(Vector2.ZERO) # this prevents getting the collision report stuck on the last collider
