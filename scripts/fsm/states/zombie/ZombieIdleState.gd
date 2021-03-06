class_name ZombieIdleState extends State

var update_delay := rand_range(4.0, 6.0)
var last_update := 0.0

func _init(owner).(owner):
	pass

func get_name():
	return "idle"

func enter_state(args) -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	
	last_update = 0.0

	owner.waypoints = []
	owner.get_node("CollisionShape2D").set_deferred("disabled", false)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", false)
	
	anim_p.queue("{0}_{1}".format({0:get_name(),1:facing}))

func update(delta) -> void:
	if owner.knows_about > 0.0:
		owner.knows_about -= delta

	if !owner.can_move:
		return

	last_update += delta

	if last_update >= update_delay && (owner.target == null || owner.target is Vector2):
		var target_pos := owner.global_position + Vector2(1.0,1.0).rotated(deg2rad(randi()%360)) * 50
		target_pos.x = clamp(target_pos.x, 32, Global.MAP_SIZE.x - 32)
		target_pos.y = clamp(target_pos.y, 32, Global.MAP_SIZE.y - 32)
		owner.target = target_pos
		last_update = 0.0

	if owner.target != null:
		owner.fsm.travel_to(owner.states.walk, null)
		return

	if !owner.is_visible_in_viewport():
		return
#
	owner.vel = lerp(owner.vel, Vector2.ZERO, .5)
	owner.vel = owner.move_and_slide(owner.vel)
