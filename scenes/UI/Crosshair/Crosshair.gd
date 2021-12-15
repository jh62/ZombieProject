extends Area2D

const CROSSHAIR_CIRCLE_NORMAL := preload("res://assets/ui/cursors/crosshair_1.png")
const CROSSHAIR_CIRCLE_SMALL := preload("res://assets/ui/cursors/crosshair_2.png")
const CROSSHAIR_SQUARE := preload("res://assets/ui/cursors/crosshair_3.png")

onready var mobile := get_tree().current_scene.get_node("TileMap/Entities/Mobs/Player")
onready var n_ProgressWheel := $CanvasLayer/TextureProgress

func _ready():
	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")

func _process(delta):
	if mobile.busy_time > 0.0 && mobile.get_equipped() is Firearm:
		n_ProgressWheel.rect_global_position = get_global_mouse_position()
		n_ProgressWheel.value = mobile.busy_time
	else:
		n_ProgressWheel.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Player_on_death():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_item_pickedup(item):
	if item is MeleeWeapon:
		Input.set_custom_mouse_cursor(CROSSHAIR_SQUARE, Input.CURSOR_ARROW, Vector2(32,32))
	else:
		Input.set_custom_mouse_cursor(CROSSHAIR_CIRCLE_NORMAL, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_search_start(mob):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Player_on_search_end(mob):
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_Player_on_aiming_start(mob):
	Input.set_custom_mouse_cursor(CROSSHAIR_SQUARE, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_aiming_stop(mob):
	Input.set_custom_mouse_cursor(CROSSHAIR_CIRCLE_NORMAL, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_busy_time_added(time):
	n_ProgressWheel.max_value = time
	n_ProgressWheel.value = time
	n_ProgressWheel.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
