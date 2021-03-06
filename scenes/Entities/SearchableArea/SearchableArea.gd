class_name SearchableArea extends Area2D

signal on_search_successful

const audio_search_end := preload("res://assets/sfx/misc/search_end.wav")

export var lootpack := {
#	1.0: preload("res://scenes/Entities/Items/Pickable/LootItem/LootItem.tscn"),
	0.4: preload("res://scenes/Entities/Items/Pickable/PickableWeapon/PickableWeapon.tscn"),
	0.28: preload("res://scenes/Entities/Items/Pickable/Medkit/Medkit.tscn")
}

export var radius := 6 setget set_radius
export var min_amount := 1
export var max_amount := 5
export var fill_time := 3.5

onready var progress_wheel := $CanvasLayer/ProgressWheel
onready var icon := $CanvasLayer/TextureRect

var searched_by : Node2D
var searching := false setget, is_searching
var looted := false setget ,is_looted

func _ready():
	$CollisionShape2D.shape.radius = radius
	$CanvasLayer/ProgressWheel.fill_time = fill_time
	icon.visible = false
	show_label(false)

	if Globals.CINEMATIC_MODE:
		$CanvasLayer.layer = -1000
		$CanvasLayer_Label.layer = -1000

func is_looted() -> bool:
	return looted

func is_searching() -> bool:
	return searching

func is_searchable() -> bool:
	return !is_searching() && !is_looted()

func _on_SearchableArea_body_entered(body : Node2D):
	if !is_searchable():
		return

	body = body as Player

	if !body.is_connected("on_search_start", self, "_on_search_start"):
		body.connect("on_search_start", self, "_on_search_start")

	if !body.is_connected("on_search_end", self, "_on_search_end"):
		body.connect("on_search_end", self, "_on_search_end")

	icon.visible = true
	icon.rect_position = global_position
	show_label(true)

func _on_SearchableArea_body_exited(body : Node2D):
	if !is_searchable():
		return

	body = body as Player

	if body.is_connected("on_search_start", self, "_on_search_start"):
		body.disconnect("on_search_start", self, "_on_search_start")

	if body.is_connected("on_search_end", self, "_on_search_end"):
		body.disconnect("on_search_end", self, "_on_search_end")

	icon.visible = false
	show_label(false)

	if searched_by == body:
		searched_by = null
		searching = false
		progress_wheel.stop()

func _on_search_start(mob) -> void:
	if !is_searchable():
		return

	if mob.fsm.current_state.get_name().begins_with("search"):
		return

#	if global_position.distance_to(mob.global_position) > (radius * 2.0):
#		return

	var _facing = mob.global_position.direction_to(global_position).round()
	mob.facing = _facing

	progress_wheel.value = 0

	if !is_connected("on_search_successful", mob, "stop_search"):
		connect("on_search_successful", mob, "stop_search")

	mob.begin_search()

	icon.visible = false
	show_label(false)

	searched_by = mob
	searching = true
	progress_wheel.rect_position = mob.global_position
	progress_wheel.rect_position.x -= progress_wheel.rect_size.x * .5
	progress_wheel.rect_position.y -= mob.get_node("Sprite").region_rect.size.y * 1.5

	if progress_wheel.rect_position.y < 0:
		progress_wheel.rect_position.y += 32

	progress_wheel.start()

func _on_search_end(mob) -> void:
	if is_connected("on_search_successful", mob, "stop_search"):
		disconnect("on_search_successful", mob, "stop_search")


	searched_by = null
	searching = false
	icon.visible = !looted
	show_label(!looted)
	progress_wheel.stop()

	mob.stop_search()

func _on_ProgressWheel_on_progress_complete():
	looted = true
	progress_wheel.stop()
	spawn_loot()

	emit_signal("on_search_successful")
	EventBus.emit_signal("play_sound", audio_search_end, global_position)

func spawn_loot() -> void:
	var _item = preload("res://scenes/Entities/Items/Pickable/LootItem/LootItem.tscn")

	for val in lootpack.keys():
		var chance := randf()

		if val < chance:
			continue

		_item = lootpack[val]
		break

	var amount := (randi() % max_amount + min_amount) if (_item.instance() is LootItem) else 1

	for i in amount:
		EventBus.emit_signal("on_object_spawn", _item, global_position)
		yield(get_tree().create_timer(0.015),"timeout")

func set_radius(new_radius) -> void:
	radius = new_radius
	$CollisionShape2D.shape.radius = new_radius

func show_label(_visible) -> void:
#	label.visible = _visible
	var _text := ""

	if _visible:
		var parent := get_parent()
		var item_name := ""

		if parent != null && parent.has_method("get_item_name"):
			item_name = parent.get_item_name()

		var button = InputMap.get_action_list("action_alt")[0].as_text()

		if Global.GameOptions.gameplay.joypad:
			button = "action"

		_text = "[center]Press [color=#fffc00]{0}[/color] to search [color=#fffc00]{1}[/color][/center]".format({0:button,1:item_name.to_upper()})

#		label.bbcode_text = "[center]Press [color=#fffc00]{0}[/color] to search [color=#fffc00]{1}[/color][/center]".format({0:button,1:item_name.to_upper()})

	EventBus.emit_signal("on_tooltip", _text)
