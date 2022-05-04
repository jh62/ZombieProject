class_name FenceGate extends Door


func _ready():
	activate_door()
	tiles_blocked = [Vector2.ZERO, Vector2.LEFT, Vector2.RIGHT]

func _unhandled_input(event):
	if !event.is_action_pressed("action_alt"):
		return

	if n_AreaDoor.get_overlapping_bodies().empty():
		return

	var body : Node2D = n_AreaDoor.get_overlapping_bodies()[0]
	var is_facing := body.global_position.direction_to(global_position).dot(body.facing) > 0

	if !is_facing:
		return

	if OS.get_system_time_msecs() - last_open_elapsed < OPEN_DELAY:
		return

	last_open_elapsed = OS.get_system_time_msecs()

	is_open = !is_open
	activate_door()
	emit_signal("on_door_used", global_position, tiles_blocked)

func activate_door() -> void:
	if is_open:
		$AnimationPlayer.play("open")
		is_open = true
	else:
		$AnimationPlayer.play("close")
		is_open = false

	_update_tooltip()
