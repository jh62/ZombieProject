extends Area2D

const CROSSHAIR_CIRCLE_NORMAL := preload("res://assets/ui/cursors/crosshair_1.png")
const CROSSHAIR_CIRCLE_SMALL := preload("res://assets/ui/cursors/crosshair_2.png")
const CROSSHAIR_SQUARE := preload("res://assets/ui/cursors/crosshair_3.png")

onready var mobile := get_tree().current_scene.get_node("TileMap/Entities/Mobs/Player")
onready var n_ProgressWheel := $CanvasLayer/TextureProgress

func _ready():
	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")
	_on_item_pickedup(mobile.get_equipped())

onready var texx := $CanvasLayer2/TextureRect

func _process(delta):
	var joy_x = Input.get_joy_axis(0, JOY_AXIS_2)
	var joy_y = Input.get_joy_axis(0 ,JOY_AXIS_3)

	texx.rect_position += Vector2(joy_x, joy_y) * 100.0 * delta

	texx.rect_position.x = clamp(texx.rect_position.x, -(texx.rect_size.x / 2), 320 - (texx.rect_size.x / 2))
	texx.rect_position.y = clamp(texx.rect_position.y, -(texx.rect_size.y / 2), 180 - (texx.rect_size.x / 2))

	if mobile.busy_time > 0.0 && mobile.get_equipped() is Firearm:
		n_ProgressWheel.rect_global_position = get_global_mouse_position()
		n_ProgressWheel.value = mobile.busy_time
	else:
		n_ProgressWheel.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Player_on_death():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(Global.POINTER_64, Input.CURSOR_ARROW, Vector2(0,0))

func _on_item_pickedup(item):
	if item is MeleeWeapon:
		Input.set_custom_mouse_cursor(CROSSHAIR_SQUARE, Input.CURSOR_ARROW, Vector2(32,32))
	else:
		Input.set_custom_mouse_cursor(CROSSHAIR_CIRCLE_NORMAL, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_search_start(mob := null):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Player_on_search_end(mob := null):
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_Player_on_aiming_start(mob := null):
	Input.set_custom_mouse_cursor(CROSSHAIR_SQUARE, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_aiming_stop(mob := null):
	Input.set_custom_mouse_cursor(CROSSHAIR_CIRCLE_NORMAL, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_busy_time_added(time):
	n_ProgressWheel.max_value = time
	n_ProgressWheel.value = time
	n_ProgressWheel.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_Bike_on_full_tank():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(Global.POINTER_64, Input.CURSOR_ARROW, Vector2(0,0))
