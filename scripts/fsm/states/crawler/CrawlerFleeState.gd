class_name CrawlerFleeState extends State

const CrawlerCrySound := preload("res://assets/sfx/mobs/crawler/misc/crawler_cry.wav")

var flee_positions := [
	Vector2.ZERO,
	Vector2(Global.MAP_SIZE.x, 0),
	Vector2(0, Global.MAP_SIZE.y),
	Vector2(Global.MAP_SIZE.x, Global.MAP_SIZE.y)
]

var update_delay := rand_range(.5, 0.650) #650
var growl_delay := rand_range(18.0, 24.0)
var flee_delay := rand_range(5.0, 10.0)

var wp_idx := 0
var last_update := 0.0
var last_growl := 0.0
var flee_time := 0.0

var threat : Node2D
var steering_force := Vector2()

func _init(owner, _threat).(owner):
	threat = _threat

func get_name():
	return "walk"

func update_waypoints(target : Vector2) -> void:
	owner.waypoints = owner.map.get_waypoint_nav(owner.global_position, target)
	wp_idx = 0

var check := false

func enter_state() -> void:
	check = true
	owner.target = _get_new_flee_position(owner.global_position, 200, threat.facing)
	update_waypoints(owner.target)

	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

	EventBus.emit_signal("play_sound", CrawlerCrySound, owner.global_position)

func update(delta) -> void:
	if threat in owner.area_attack.get_overlapping_bodies():
		var new_state = owner.States.attack.new(owner, threat)
		owner.fsm.travel_to(new_state)
		return

	if !owner.can_move || threat == null || !threat.is_alive():
		var state = owner.States.idle.new(owner)
		owner.fsm.travel_to(state)
		return

	if flee_time >= flee_delay:
		flee_time = 0.0

		var is_in_view = owner.is_visible_in_viewport()
		var is_looking = threat.global_position.direction_to(owner.global_position).dot(threat.facing) > 0.0

		if !is_in_view && is_looking:
			return

		if !is_looking:
			owner.target = threat
			var state = owner.States.walk.new(owner)
			owner.fsm.travel_to(state)
			return

		var space := owner.get_world_2d().direct_space_state
		var is_block_los := space.intersect_ray(owner.global_position, threat.global_position, [owner], 9, true, false)

		if is_block_los:
			owner.target = threat
			var state = owner.States.walk.new(owner)
			owner.fsm.travel_to(state)
			return

	last_update += delta
	flee_time += delta

	if last_update >= update_delay:
		update_waypoints(owner.target)
		last_update = 0.0
		return	

	if wp_idx >= owner.waypoints.size():
		owner.target = _get_new_flee_position(owner.global_position, 200, threat.facing)
		update_waypoints(owner.target)
		last_update = 0.0
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
		owner.vel = owner.move_and_slide(owner.vel * 2.0)
	else:
		owner.vel = owner.speed * owner.dir
		owner.vel = owner.vel.move_toward(steering_force, delta)
		owner.global_position = owner.global_position.linear_interpolate(owner.global_position + owner.vel, delta)

func _get_new_flee_position(from_pos : Vector2, radius : int, threat_facing : Vector2) -> Vector2:
	var new_target := from_pos + Vector2(randi()%radius,randi()%radius) * -threat_facing
	new_target.x = clamp(new_target.x, 0, Global.MAP_SIZE.x)
	new_target.y = clamp(new_target.y, 0, Global.MAP_SIZE.y)
	return new_target
