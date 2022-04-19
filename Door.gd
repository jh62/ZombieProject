tool
class_name Door extends StaticObject

signal on_door_used(position)

const OPEN_DELAY := 700.0

enum DoorType {
	Type1,
	Type2,
	Type3,
	Type4
}

export(DoorType) var door_type := DoorType.Type1 setget set_door_type

var last_open_elapsed := 0.0

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

	$CollisionShape.disabled = !$CollisionShape.disabled
	$Sprite.visible = !$CollisionShape.disabled
	last_open_elapsed = OS.get_system_time_msecs()
	_update_tooltip()
	emit_signal("on_door_used", global_position)

func set_door_type(value) -> void:
	var type = clamp(value, 0, DoorType.values().size())
	door_type = type
	$Sprite.frame = type

func is_open() -> bool:
	return !$CollisionShape.disabled

func _on_AreaDoor_body_entered(body):
	_update_tooltip()

func _on_AreaDoor_body_exited(body):
	EventBus.emit_signal("on_tooltip", "")

func _update_tooltip() -> void:
	var button = InputMap.get_action_list("action_alt")[0].as_text()
	var _text = "[center]Press [color=#fffc00]{0}[/color] to {1} [color=#de2d22]DOOR[/color][/center]".format({0:button,1:("open" if is_open() else "close")})
	EventBus.emit_signal("on_tooltip", _text)
