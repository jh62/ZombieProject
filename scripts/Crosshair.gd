extends AnimatedSprite

const CROSSHAIR_CIRCLE_NORMAL := "crosshair_1"
const CROSSHAIR_CIRCLE_SMALL := "crosshair_2"
const CROSSHAIR_SQUARE := "crosshair_3"
const CROSSHAIR_NE := "crosshair_ne"
const CROSSHAIR_E := "crosshair_e"

var pointer := false
var mobile : Node2D

func _ready():
	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")
	visible = true

func _unhandled_input(event):
	if !(event is InputEventMouseMotion):
		return

	if pointer:
		var origin := get_viewport_rect().size / 2
		var dir := mobile.global_position.direction_to(global_position)
		var facing := Mobile.get_facing_as_string(dir)
		print_debug(dir)
		if dir.y != 0 && abs(dir.y) > .25:
			if dir.x != 0 && abs(dir.x) < 0.25:
				play(CROSSHAIR_E)

				if dir.y > 0:
					rotation_degrees = 90
				elif dir.y < 0:
					rotation_degrees = -90
				else:
					rotation = 0
				flip_h = false
				flip_v = false
			else:
				play(CROSSHAIR_NE)
				rotation = 0
				flip_h = dir.x < 0
				flip_v = dir.y > 0
		else:
			play(CROSSHAIR_E)
			flip_h = dir.x < 0
			flip_v = false
			rotation = 0

func _process(delta):
	global_position = get_global_mouse_position()

func _on_Player_on_death():
	visible = true

func _on_item_pickedup(item):
	if item is MeleeWeapon:
		pointer = true
		mobile = item.equipper
	else:
		pointer = false
		play(CROSSHAIR_CIRCLE_NORMAL)

func _on_Player_on_search_start(mob):
	visible = false

func _on_Player_on_search_end(mob):
	visible = true

func _on_Player_on_aiming_start(mob):
	play(CROSSHAIR_CIRCLE_SMALL)

func _on_Player_on_aiming_stop(mob):
	if !pointer:
		play(CROSSHAIR_CIRCLE_NORMAL)
