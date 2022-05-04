tool
class_name Door extends StaticObject

signal on_door_used(position, tiles_blocked)

const OPEN_DELAY := 700.0

enum DoorType {
	Type1,
	Type2,
	Type3,
	Type4,
	Type5
}

export(DoorType) var door_type := DoorType.Type1 setget set_door_type
export var is_open := false
export var blocks_tile := false

onready var n_AreaDoor := $AreaDoor

var last_open_elapsed := 0.0
var tiles_blocked := [Vector2.ZERO]

func _ready():
	activate_door()

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

	is_open = !is_open
	activate_door()
	emit_signal("on_door_used", global_position, tiles_blocked)

func activate_door() -> void:
	$CollisionShape.disabled = !is_open
	$Sprite.visible = is_open
	last_open_elapsed = OS.get_system_time_msecs()
	_update_tooltip()

func set_door_type(value) -> void:
	var type = clamp(value, 0, DoorType.values().size())
	door_type = type
	$Sprite.frame = type

func _on_AreaDoor_body_entered(body):
	_update_tooltip()

func _on_AreaDoor_body_exited(body):
	EventBus.emit_signal("on_tooltip", "")

func _update_tooltip() -> void:
	var button = InputMap.get_action_list("action_alt")[0].as_text()
	var _text = "[center]Press [color=#fffc00]{0}[/color] to {1} [color=#de2d22]DOOR[/color][/center]".format({0:button,1:("open" if !is_open else "close")})
	EventBus.emit_signal("on_tooltip", _text)

func _on_VisibilityNotifier2D_screen_entered():
	set_process(true)
	set_physics_process(true)
	n_Area2d.monitorable = true
	n_Area2d.monitorable = true

func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)
	set_physics_process(false)
	n_Area2d.monitorable = false
	n_Area2d.monitorable = false
