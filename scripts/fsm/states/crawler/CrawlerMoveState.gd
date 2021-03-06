class_name CrawlerMoveState extends State

var update_delay := rand_range(.650, .850) #650
var growl_delay := rand_range(18.0, 32.0)

var wp_idx := 0
var last_update := 0.0
var last_growl := 0.0

var steering_force := Vector2()
var push_force := Vector2()

func _init(owner).(owner):
	pass

func get_name():
	return "walk"

func update_waypoints(target) -> void:
	var target_pos = target if (target is Vector2) else target.global_position
	owner.waypoints = owner.map.get_waypoint_nav(owner.global_position, target_pos)
	wp_idx = 0

func enter_state(args) -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	
	wp_idx = 0
	last_update = 0.0
	last_growl = 0.0
	steering_force = Vector2()
	push_force = Vector2()

	if owner.target != null:
		update_waypoints(owner.target)
		
	anim_p.queue("{0}_{1}".format({0:get_name(),1:facing}))

func update(delta) -> void:
	if !owner.can_move || (owner.target == null && owner.waypoints.empty()):
		owner.fsm.travel_to(owner.states.idle, null)
		return

	if (owner.target is Mobile):
		if owner.target in owner.area_attack.get_overlapping_bodies():
			owner.fsm.travel_to(owner.states.attack, {
				"target": owner.target
			})
			return

		if owner.is_visible_in_viewport():
			var facing_direction = owner.target.global_position.direction_to(owner.global_position).dot(owner.target.facing)

			if facing_direction > 0:
				var space := owner.get_world_2d().direct_space_state
				var is_block_los := space.intersect_ray(owner.global_position, owner.target.global_position, [owner], 9, true, false)

				if !is_block_los:
					owner.fsm.travel_to(owner.states.flee, {
						"threat": owner.target
					})
					return

	last_update += delta

	if last_update >= update_delay && owner.target != null:
		update_waypoints(owner.target)
		last_update = 0
		return	

	if wp_idx >= owner.waypoints.size():
		if (owner.target is Vector2):
			owner.target = null
		owner.fsm.travel_to(owner.states.idle, null)
		return
	
	var facing := Mobile.get_facing_as_string(owner.facing)
	owner.get_anim_player().play("{0}_{1}".format({0:get_name(),1:facing}))

	var wp_pos = owner.waypoints[wp_idx]
	var dist = owner.global_position.distance_to(wp_pos)

	owner.dir = owner.global_position.direction_to(wp_pos).normalized()

	if dist < 8.0:
		wp_idx += 1

	if owner.is_visible_in_viewport():

		if last_growl >= growl_delay:
			last_growl = 0.0
			owner.play_random_sound()
		else:
			last_growl += delta

		var closest : Node2D
		var force := Vector2()
		var neighbors := 0

		var ahead = owner.global_position + owner.vel.normalized() * 8.0

		for body in owner.area_soft.get_overlapping_bodies():
			push_force = ahead - (body.global_position + Vector2(8,8))
			push_force = push_force.normalized() * 4.0

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
			steering_force = steering_force.normalized() * 40.0

		if closest != null:
			var zomb_v = closest.vel * -1
			zomb_v = zomb_v.normalized() * 2.0
			steering_force += closest.global_position + zomb_v
			steering_force = steering_force.clamped(8.0)

	owner.vel = owner.speed * owner.dir
	owner.vel += steering_force + push_force
	owner.global_position = owner.global_position.move_toward(owner.global_position + owner.vel, delta * owner.speed)
