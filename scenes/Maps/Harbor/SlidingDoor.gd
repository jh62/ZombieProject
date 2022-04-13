extends StaticObject

const OPEN_DELAY := 700.0

var last_open_elapsed := 0.0
var is_open := false

func _ready():
	pass

func _unhandled_input(event):
	if !event.is_action_pressed("action_alt"):
		return

	if $AreaDoor.get_overlapping_bodies().empty():
		return

	var body : Node2D = $AreaDoor.get_overlapping_bodies()[0]
	var is_facing := body.global_position.direction_to(global_position).dot(body.facing) > 0

	if !is_facing:
		return

	if OS.get_system_time_msecs() - last_open_elapsed < OPEN_DELAY:
		return

	last_open_elapsed = OS.get_system_time_msecs()

	if is_open:
		$AnimationPlayer.play("close")
		is_open = false
	else:
		$AnimationPlayer.play("open")
		is_open = true
