class_name ZombieIdleState extends State

var update_delay : float
var last_update := 0

func _init(owner).(owner):
	pass

func get_name():
	return "idle"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.waypoints = []
	owner.get_node("CollisionShape2D").set_deferred("disabled", false)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", false)

	update_delay = randi() % 600 + 2000
	last_update = OS.get_ticks_msec()

func update(delta) -> void:
	if !owner.can_move:
		return

	var now := OS.get_ticks_msec() - last_update

	if now > update_delay:
		var target_pos := owner.global_position + Vector2(1.0,1.0).rotated(deg2rad(randi()%360)) * 50
		target_pos.x = clamp(target_pos.x, 32, Global.MAP_SIZE.x - 32)
		target_pos.y = clamp(target_pos.y, 32, Global.MAP_SIZE.y - 32)
		var new_target = owner.map.get_waypoints_to(owner.global_position, target_pos)
		owner.target = new_target
#
	var target = owner.target

	if target != null || !owner.waypoints.empty():
		var new_state = owner.States.walk.new(owner)
		owner.fsm.travel_to(new_state)
		return

	if !owner.is_visible_in_viewport():
		return
#
	owner.vel = lerp(owner.vel, Vector2.ZERO, .5)
	owner.vel = owner.move_and_slide(owner.vel)
