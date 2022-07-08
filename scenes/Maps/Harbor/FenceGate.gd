class_name FenceGate extends Door

const SOUND_SLIDE := preload("res://assets/sfx/misc/fence_slide.wav")

func _ready():
	activate_door()
	tiles_blocked = [Vector2.ZERO, Vector2.LEFT, Vector2.RIGHT]

func on_action_pressed(event, facing) -> void:
	if event != EventBus.ActionEvent.USE_KEY:
		return
	
	if n_AreaDoor.get_overlapping_bodies().empty():
		return
		
	var body : Node2D = n_AreaDoor.get_overlapping_bodies()[0]
	var is_facing := body.global_position.direction_to(global_position).dot(body.facing) > 0

	if !is_facing:
		return

	if OS.get_system_time_msecs() - last_open_elapsed < OPEN_DELAY:
		return
		
	if !check_key(body):
		EventBus.emit_signal("play_sound", SOUND_LOCKED, global_position)
		EventBus.emit_signal("on_tooltip", "Gate is closed. You need a key.")
		return

	last_open_elapsed = OS.get_system_time_msecs()

	is_closed = !is_closed
	activate_door()
	emit_signal("on_door_used", global_position, tiles_blocked)
	EventBus.emit_signal("play_sound", SOUND_SLIDE, global_position)
	
	for b in $AreaOpen.get_overlapping_bodies():
		if b.is_alive() && b.can_move:
			b.search_nearby()
	
func _unhandled_input(event):
	return

func activate_door() -> void:
	if is_closed:
		$AnimationPlayer.play("open")
		is_closed = true
	else:
		$AnimationPlayer.play("close")
		is_closed = false

	_update_tooltip()
