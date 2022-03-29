class_name ZombieMoveState extends State

var growl_delay := randi() % 15000 + 15000
var last_growl := 0.0

var wp_idx := 0
var last_update := 0
var update_delay := 650 #650
var knows_about := 0.0

func _init(owner).(owner):
	pass

func get_name():
	return "walk"

func update_waypoints(target) -> void:
	var target_pos = target if (target is Vector2) else target.global_position
	owner.waypoints = owner.nav.get_simple_path(owner.global_position, target_pos, true)
	wp_idx = 0

func enter_state() -> void:
	wp_idx = 0
	last_growl = OS.get_ticks_msec()

	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

	if owner.target != null:
		update_waypoints(owner.target)

		if owner.target is Mobile:
			knows_about = 7.0

func update(delta) -> void:
	if !owner.can_move:
		var state = owner.States.idle.new(owner)
		owner.fsm.travel_to(state)
		return

	var target = owner.target

	if owner.dir.length() != 0: # is going somewhere
		if (target == null && owner.waypoints.empty()) || ((target is Mobile) && (target.is_eaten || !target.is_alive())):
			var new_state = owner.States.idle.new(owner)
			owner.fsm.travel_to(new_state)
			return

	if owner.is_visible_in_viewport():
		last_growl += delta

		if OS.get_ticks_msec() - last_growl > growl_delay:
			last_growl = OS.get_ticks_msec()
			owner.play_random_sound()

	if target != null:
		if (target is Mobile):
			if !owner.area_perception.overlaps_body(target):
				knows_about -= delta
				if knows_about <= 0:
					owner.target = null
					return

		var _now = OS.get_ticks_msec() - last_update

		if _now > update_delay:
			update_waypoints(owner.target)
			last_update = OS.get_ticks_msec()

	if owner.waypoints.empty() || wp_idx >= owner.waypoints.size():
		if (target is Vector2):
			owner.target = null
		var new_state = owner.States.idle.new(owner)
		owner.fsm.travel_to(new_state)
		return

	var wp : Vector2 = owner.waypoints[wp_idx]
	owner.dir = owner.global_position.direction_to(wp)

	if owner.global_position.distance_to(wp) < 4.0:
		wp_idx += 1

	var facing := Mobile.get_facing_as_string(owner.facing)
	owner.get_anim_player().play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.vel += owner.speed * owner.dir


	if owner.is_visible_in_viewport():
		if owner.get_slide_count() > 0:
			var collision = owner.get_slide_collision(0)
			var collider = collision.collider
			if collider is Mobile:

				if collider is Player:
					var p = collider as Player
					if p.is_alive():
						var new_state = owner.States.attack.new(owner, p)
						owner.fsm.travel_to(new_state)
				else:
					var p = collider as Mobile
					if p.fsm.current_state.get_name().begins_with("idle"):
						p.target = p.global_position + (collision.normal * 16.0)
					else:
						if owner.target == null || !(owner.target is Mobile):
							owner.target = owner.global_position + (collision.normal * 16.0)
						else:
							owner.vel = collision.normal * 16.0
			else:
				pass

	owner.vel = owner.move_and_slide(owner.vel)
	owner.vel = owner.vel.clamped(owner.max_speed)
