tool
class_name Door extends StaticObject

signal on_door_used(position, tiles_blocked)

const OPEN_DELAY := 700.0
const SOUND_LOCKED := preload("res://assets/sfx/misc/door_locked.wav")

const SOUNDS := {
	MaterialType.WOOD:[
		preload("res://assets/sfx/misc/door_wood_open.wav"),
		preload("res://assets/sfx/misc/door_wood_closed.wav")
	],
	MaterialType.METAL: [
		preload("res://assets/sfx/misc/door_metal_open.wav"),
		preload("res://assets/sfx/misc/door_metal_closed.wav")
	],
}

export var door_type := 0 setget set_door_type
export var is_open := false
export var key_id := -1
export var blocks_tile := false

onready var n_AreaDoor := $AreaDoor

var last_open_elapsed := 0.0
var tiles_blocked := [Vector2.ZERO]

func _ready():
	EventBus.connect("action_pressed", self, "on_action_pressed")
	activate_door()

func on_action_pressed(event, facing) -> void:
	if event != EventBus.ActionEvent.USE_KEY:		
		return
	
	if $AreaDoor.get_overlapping_bodies().empty():
		return
	
	var body : Node2D = $AreaDoor.get_overlapping_bodies()[0]
	var is_facing := body.global_position.direction_to(global_position).dot(body.facing) > 0

	if !is_facing:
		return

	if OS.get_system_time_msecs() - last_open_elapsed < OPEN_DELAY:
		return
	
	if !check_key(body):
		EventBus.emit_signal("play_sound", SOUND_LOCKED, global_position)
		EventBus.emit_signal("on_tooltip", "Gate is closed. You need a key.")
		return
	
	is_open = !is_open
	activate_door()
	emit_signal("on_door_used", global_position, tiles_blocked)
	
	var sound := 1 if is_open else 0
	EventBus.emit_signal("play_sound", SOUNDS[material_type][sound], global_position)

func check_key(body : Node2D) -> bool:
	if key_id == -1:
		return true
		
	var _key_other = body.find_node("*Key*", true, false)
	
	if _key_other == null:
		return false
		
	if _key_other.key_id != key_id:
		return false
	
	_key_other.play_sound()
	_key_other.queue_free()
	key_id = -1
	
	return true

func activate_door() -> void:
	$CollisionShape.disabled = !is_open
	$Sprite.visible = is_open
	last_open_elapsed = OS.get_system_time_msecs()
	_update_tooltip()
	
	for b in $AreaOpen.get_overlapping_bodies():
		if b.is_alive() && b.can_move:
			b.search_nearby()

func set_door_type(value) -> void:
	door_type = clamp(value, 0, $Sprite.hframes * $Sprite.vframes)
	$Sprite.frame = door_type
		
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
