extends AnimatedSprite

const CROSSHAIR_CIRCLE_NORMAL := preload("res://assets/ui/cursors/crosshair_1.png")
const CROSSHAIR_CIRCLE_SMALL := preload("res://assets/ui/cursors/crosshair_2.png")
const CROSSHAIR_SQUARE := preload("res://assets/ui/cursors/crosshair_3.png")

var mobile : Node2D

func _ready():
	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")

func _unhandled_input(event):
	if !(event is InputEventMouseMotion):
		return

	global_position = get_global_mouse_position()

func _on_Player_on_death():
	pass

func _on_item_pickedup(item):
	if item is MeleeWeapon:
		Input.set_custom_mouse_cursor(CROSSHAIR_SQUARE, Input.CURSOR_ARROW, Vector2(32,32))
	else:
		Input.set_custom_mouse_cursor(CROSSHAIR_CIRCLE_NORMAL, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_search_start(mob):
	visible = false

func _on_Player_on_search_end(mob):
	pass

func _on_Player_on_aiming_start(mob):
	Input.set_custom_mouse_cursor(CROSSHAIR_SQUARE, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_aiming_stop(mob):
	Input.set_custom_mouse_cursor(CROSSHAIR_CIRCLE_NORMAL, Input.CURSOR_ARROW, Vector2(32,32))
