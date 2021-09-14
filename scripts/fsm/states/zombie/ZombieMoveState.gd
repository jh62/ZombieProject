class_name ZombieMoveState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "walk"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

func update(delta) -> void:
	var target = owner.target
	
	if target == null && owner.dir.length() == 0 :
		var new_state = owner.States.idle.new(owner)
		owner.fsm.travel_to(new_state)
		return	
	
	if target is Node2D:
		owner.dir = owner.global_position.direction_to(target.global_position)
	elif target is Vector2:
		owner.dir = owner.global_position.direction_to(target)
		
	
	var facing := Mobile.get_facing_as_string(owner.facing)
	owner.get_anim_player().play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.vel += owner.speed * owner.dir
	owner.vel = owner.move_and_slide(owner.vel)
	owner.vel = owner.vel.clamped(owner.speed)

	if owner.get_slide_count() > 0:
		var collider = owner.get_slide_collision(0).collider
		if collider is Player:
			var p = collider as Player
			
			if p.is_alive():
				var new_state = owner.States.attack.new(owner, p)
				owner.fsm.travel_to(new_state)
			elif !p.is_eaten:
				var new_state = owner.States.eat_wait.new(owner, p)
				owner.fsm.travel_to(new_state)
			return
