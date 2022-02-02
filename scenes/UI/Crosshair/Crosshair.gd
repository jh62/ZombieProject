extends Area2D

const CROSSHAIR_CIRCLE_NORMAL := preload("res://assets/ui/cursors/crosshair_1.png")
const CROSSHAIR_CIRCLE_SMALL := preload("res://assets/ui/cursors/crosshair_2.png")
const CROSSHAIR_SQUARE := preload("res://assets/ui/cursors/crosshair_3.png")

const MOUSE_SENSITIVITY := 2.5
const JOYPAD_SENSITIVITY = 5.0

#onready var mobile := get_tree().current_scene.get_node("TileMap/Entities/Mobs/Player")
onready var mobile := get_parent()
onready var n_ProgressWheel := $CanvasLayer/TextureProgress
onready var n_CrosshairTexture := $CanvasLayer2/TextureCrosshair

export var sensitivity := 2.5

func _ready():
	if Global.GameOptions.gameplay.joypad:
		n_CrosshairTexture.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		n_CrosshairTexture.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")
	yield(get_tree().create_timer(.1),"timeout")
	_on_item_pickedup(mobile.get_equipped())

func _process(delta):
	if Global.GameOptions.gameplay.joypad:
		var joy := Vector2(Input.get_joy_axis(0, JOY_AXIS_2), Input.get_joy_axis(0 ,JOY_AXIS_3)).normalized()

		position += joy * sensitivity
		position.x = clamp(position.x, -(n_CrosshairTexture.rect_size.x / 2), 320 - (n_CrosshairTexture.rect_size.x / 2))
		position.y = clamp(position.y, -(n_CrosshairTexture.rect_size.y / 2), 180 - (n_CrosshairTexture.rect_size.x / 2))
		n_CrosshairTexture.rect_position = position

	if mobile.busy_time > 0.0 && mobile.get_equipped() is Firearm:
		n_ProgressWheel.rect_global_position = get_global_mouse_position()
		n_ProgressWheel.value = mobile.busy_time
	else:
		n_ProgressWheel.visible = false

		if Global.GameOptions.gameplay.joypad:
			n_CrosshairTexture.visible = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Player_on_death():
	if Global.GameOptions.gameplay.joypad:
		n_CrosshairTexture.texture = Global.POINTER_64
		n_CrosshairTexture.visible = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(Global.POINTER_64, Input.CURSOR_ARROW, Vector2(0,0))

func _on_item_pickedup(item):
	if item is MeleeWeapon:
		if Global.GameOptions.gameplay.joypad:
			n_CrosshairTexture.texture = CROSSHAIR_SQUARE
			sensitivity = JOYPAD_SENSITIVITY
		else:
			Input.set_custom_mouse_cursor(CROSSHAIR_SQUARE, Input.CURSOR_ARROW, Vector2(32,32))
			sensitivity = MOUSE_SENSITIVITY
	else:
		if Global.GameOptions.gameplay.joypad:
			n_CrosshairTexture.texture = CROSSHAIR_CIRCLE_NORMAL
		else:
			Input.set_custom_mouse_cursor(CROSSHAIR_CIRCLE_NORMAL, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_search_start(mob := null):
	if Global.GameOptions.gameplay.joypad:
		n_CrosshairTexture.visible = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Player_on_search_end(mob := null):
	if Global.GameOptions.gameplay.joypad:
		n_CrosshairTexture.visible = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_Player_on_aiming_start(mob := null):
	if Global.GameOptions.gameplay.joypad:
		n_CrosshairTexture.texture = CROSSHAIR_SQUARE
	else:
		Input.set_custom_mouse_cursor(CROSSHAIR_SQUARE, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_aiming_stop(mob := null):
	if Global.GameOptions.gameplay.joypad:
		n_CrosshairTexture.texture = CROSSHAIR_CIRCLE_NORMAL
	else:
		Input.set_custom_mouse_cursor(CROSSHAIR_CIRCLE_NORMAL, Input.CURSOR_ARROW, Vector2(32,32))

func _on_Player_on_busy_time_added(time):
	n_ProgressWheel.max_value = time
	n_ProgressWheel.value = time
	n_ProgressWheel.visible = true

	if Global.GameOptions.gameplay.joypad:
		n_CrosshairTexture.visible = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_Bike_on_full_tank():
	if Global.GameOptions.gameplay.joypad:
		n_CrosshairTexture.visible = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(Global.POINTER_64, Input.CURSOR_ARROW, Vector2(0,0))

