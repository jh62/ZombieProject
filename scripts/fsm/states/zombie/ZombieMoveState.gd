class_name ZombieMoveState extends State

var growl_delay := randi() % 15000 + 15000
var last_growl := 0.0

func _init(owner).(owner):
	pass

func get_name():
	return "walk"

func enter_state() -> void:
	last_growl = OS.get_ticks_msec()

	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

func update(delta) -> void:
	var target = owner.target

	if owner.dir.length() != 0: #has a destination
		if target == null:
			var new_state = owner.States.idle.new(owner)
			owner.fsm.travel_to(new_state)
			return
#	if target == null && owner.dir.length() == 0:
#		var new_state = owner.States.idle.new(owner)
#		owner.fsm.travel_to(new_state)
#		return

	if owner._visible_viewport:
		last_growl += delta

		if OS.get_ticks_msec() - last_growl > growl_delay:
			last_growl = OS.get_ticks_msec()
			owner.play_random_sound()

		if target is Vector2:
			owner.dir = owner.global_position.direction_to(target)
		else:
			owner.dir = owner.global_position.direction_to(target.global_position)

	var facing := Mobile.get_facing_as_string(owner.facing)
	owner.get_anim_player().play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.vel += owner.speed * owner.dir
	owner.vel = owner.move_and_slide(owner.vel)
	owner.vel = owner.vel.clamped(owner.speed)

	if owner._visible_viewport:
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
