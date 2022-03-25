class_name CrawlerFleeState extends State

var wp_idx := 0
var last_update := 0
var update_delay := 1500 #650

var threat : Node2D

func _init(owner, _threat).(owner):
	threat = _threat

func get_name():
	return "walk"

func update_waypoints(target) -> void:
	var target_pos = target if (target is Vector2) else target.global_position
	owner.waypoints = owner.nav.get_simple_path(owner.global_position, target_pos, true)
	wp_idx = 0

func enter_state() -> void:
	wp_idx = 0
#	owner.target = _get_new_flee_position(owner.global_position, 480, threat.facing)
	owner.target = Vector2.ZERO

	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

func update(delta) -> void:
	if !owner.can_move || threat == null || !threat.is_alive():
		var state = owner.States.idle.new(owner)
		owner.fsm.travel_to(state)
		return

	var is_in_view = owner.is_visible_in_viewport()
	var is_looking = threat.global_position.direction_to(owner.global_position).dot(threat.facing)

	if !is_in_view || is_looking < 0.0:
		owner.target = threat
		var state = owner.States.walk.new(owner)
		owner.fsm.travel_to(state)
		return

	var target = owner.target
	var _now = OS.get_ticks_msec() - last_update

	if _now > update_delay:
		update_waypoints(target)
		last_update = OS.get_ticks_msec()

	if owner.waypoints.empty() || wp_idx >= owner.waypoints.size():
		owner.target = threat
		var new_state = owner.States.walk.new(owner)
		owner.fsm.travel_to(new_state)
		return

	var wp : Vector2 = owner.waypoints[wp_idx]
	owner.dir = owner.global_position.direction_to(wp)

	if owner.global_position.distance_to(wp) < 4.0:
		wp_idx += 1

	var facing := Mobile.get_facing_as_string(owner.facing)
	owner.get_anim_player().play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.vel += owner.speed * owner.dir
	owner.vel = owner.move_and_slide(owner.vel)
	owner.vel = owner.vel.clamped(owner.max_speed * 1.25)

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
						p.vel = -(collision.normal * 16.25)

func _get_new_flee_position(from, radius, facing) -> Vector2:
	var new_target : Vector2 = from + Vector2(randi()%radius,randi()%radius) * -(facing)
	new_target.x = clamp(new_target.x, 0, Global.MAP_SIZE.x)
	new_target.y = clamp(new_target.y, 0, Global.MAP_SIZE.y)
	return new_target
