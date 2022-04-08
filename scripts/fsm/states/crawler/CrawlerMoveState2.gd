class_name CrawlerMoveState2 extends State

var update_delay := rand_range(.650, .850) #650
var growl_delay := rand_range(18.0, 32.0)

var wp_idx := 0
var last_update := 0.0
var last_growl := 0.0

var steering_force := Vector2()

func _init(owner).(owner):
	pass

func get_name():
	return "walk"

func update_waypoints(target) -> void:
	var target_pos = target if (target is Vector2) else target.global_position
	owner.waypoints = owner.map.get_waypoint_nav(owner.global_position, target_pos)
	wp_idx = 0

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

	if owner.target != null:
		update_waypoints(owner.target)

func update(delta) -> void:

	if !owner.can_move || owner.target == null || owner.waypoints.empty():
		var state = owner.States.idle.new(owner)
		owner.fsm.travel_to(state)
		return

	if (owner.target is Mobile):
		if owner.target in owner.area_attack.get_overlapping_bodies():
			var new_state = owner.States.attack.new(owner, owner.target)
			owner.fsm.travel_to(new_state)
			return

		if owner.is_visible_in_viewport():
			var facing_direction = owner.target.global_position.direction_to(owner.global_position).dot(owner.target.facing)

			if facing_direction > 0:
				var space := owner.get_world_2d().direct_space_state
				var is_block_los := space.intersect_ray(owner.global_position, owner.target.global_position, [owner], 9, true, false)

				if !is_block_los:
					var new_state = owner.States.flee.new(owner, owner.target)
					owner.fsm.travel_to(new_state)
					return

	last_update += delta

	if last_update >= update_delay:
		update_waypoints(owner.target)
		last_update = 0

	var facing := Mobile.get_facing_as_string(owner.facing)
	owner.get_anim_player().play("{0}_{1}".format({0:get_name(),1:facing}))

	var wp_pos = owner.waypoints[wp_idx]
	var dist = owner.global_position.distance_to(wp_pos)

	owner.dir = owner.global_position.direction_to(wp_pos).normalized()

	if dist < 8.0:
		wp_idx += 1

	if wp_idx >= owner.waypoints.size():
		if (owner.target is Vector2):
			owner.target = null
		var new_state = owner.States.idle.new(owner)
		owner.fsm.travel_to(new_state)
		return

	if owner.is_visible_in_viewport():

		if last_growl >= growl_delay:
			last_growl = 0.0
			owner.play_random_sound()
		else:
			last_growl += delta

		var closest : Node2D
		var force := Vector2()
		var neighbors := 0

		for area in owner.area_soft.get_overlapping_areas():
			var z = area.get_parent()
			var dist_z = z.global_position.distance_to(owner.global_position)

			if closest == null || dist_z < closest.global_position.distance_to(owner.global_position):
				closest = z

			if dist_z <= 40.0:
				steering_force += z.global_position - owner.global_position
				neighbors += 1

		if neighbors != 0:
			steering_force /= neighbors
			steering_force *= -1
			steering_force = steering_force.normalized() * 400.0

		if closest != null:
			var zomb_v = closest.vel * -1
			zomb_v = zomb_v.normalized() * 2
			steering_force += closest.global_position + zomb_v
			steering_force = steering_force.clamped(8)

	owner.vel = owner.speed * owner.dir
	owner.vel = owner.vel.move_toward(steering_force, delta)
	owner.vel = owner.move_and_slide(owner.vel)
