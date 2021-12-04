extends AnimatedSprite

const CROSSHAIR_CIRCLE_NORMAL := "crosshair_1"
const CROSSHAIR_CIRCLE_SMALL := "crosshair_2"
const CROSSHAIR_SQUARE := "crosshair_3"

var mobile : Node2D

func _ready():
	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")
	visible = true

func _unhandled_input(event):
	if !(event is InputEventMouseMotion):
		return

	global_position = get_global_mouse_position()

#func _process(delta):
#	global_position = get_global_mouse_position()

func _on_Player_on_death():
	visible = true

func _on_item_pickedup(item):
	if item is MeleeWeapon:
		play(CROSSHAIR_SQUARE)
	else:
		play(CROSSHAIR_CIRCLE_NORMAL)

func _on_Player_on_search_start(mob):
	visible = false

func _on_Player_on_search_end(mob):
	visible = true

func _on_Player_on_aiming_start(mob):
	play(CROSSHAIR_CIRCLE_SMALL)

func _on_Player_on_aiming_stop(mob):
	play(CROSSHAIR_CIRCLE_NORMAL)
