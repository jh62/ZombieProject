class_name SearchableArea extends Area2D

signal on_search_successful

const audio_search_end := preload("res://assets/sfx/misc/search_end.wav")

export var lootpack := {
	.75: preload("res://scenes/Entities/Items/Pickable/LootItem/LootItem.tscn")
}

export var radius := 10 setget set_radius
export var min_amount := 1
export var max_amount := 1
export var fill_time := 3.5

onready var progress_wheel := $CanvasLayer/ProgressWheel
onready var icon := $CanvasLayer/TextureRect

var searched_by : Node2D
var searching := false setget, is_searching
var looted := false setget ,is_looted

func _ready():
	connect("on_search_successful", get_parent(), "on_search_successful")
	$CollisionShape2D.shape.radius = radius
	$CanvasLayer/ProgressWheel.fill_time = fill_time
	icon.visible = false

func is_looted() -> bool:
	return looted

func is_searching() -> bool:
	return searching

func is_searchable() -> bool:
	return !is_searching() && !is_looted()

func _on_SearchableArea_body_entered(body : Node2D):
	if !body.is_in_group(Global.GROUP_PLAYER):
		return

	if !is_searchable():
		return

	body = body as Player
	body.connect("on_search_start", self, "_on_search_start")
	body.connect("on_search_end", self, "_on_search_end")
	icon.visible = true
	icon.rect_position = global_position

func _on_SearchableArea_body_exited(body : Node2D):
	if !body.is_in_group(Global.GROUP_PLAYER):
		return

	body = body as Player
	body.disconnect("on_search_start", self, "_on_search_start")
	body.disconnect("on_search_end", self, "_on_search_end")
	icon.visible = false

	if searched_by == body:
		searched_by = null
		searching = false
		progress_wheel.stop()

func _on_search_start(mob) -> void:
	if !is_searchable():
		return

	if mob.fsm.current_state.get_name().begins_with("search"):
		return

	if !is_connected("on_search_successful", mob, "stop_search"):
		connect("on_search_successful", mob, "stop_search")

	mob.begin_search()

	icon.visible = false

	searched_by = mob
	searching = true
	progress_wheel.rect_position = mob.global_position
	progress_wheel.rect_position.x -= progress_wheel.rect_size.x * .5
	progress_wheel.rect_position.y -= mob.get_node("Sprite").region_rect.size.y * 1.5

	if progress_wheel.rect_position.y < 0:
		progress_wheel.rect_position.y += 32

	progress_wheel.start()

func _on_search_end(mob) -> void:
	mob.stop_search()

	if is_connected("on_search_successful", mob, "stop_search"):
		disconnect("on_search_successful", mob, "stop_search")

	searched_by = null
	searching = false
	icon.visible = !looted
	progress_wheel.stop()

func _on_ProgressWheel_on_progress_complete():
	looted = true
	progress_wheel.stop()
	spawn_loot()

	emit_signal("on_search_successful")
	EventBus.emit_signal("play_sound", audio_search_end, global_position)

func spawn_loot() -> void:
	for val in lootpack.keys():
		var chance := randf()

		if val < chance:
			continue

		var _item = lootpack[val]
		var amount := int(rand_range(min_amount, max_amount)) if (_item.instance() is LootItem) else 1

		for i in amount:
			EventBus.emit_signal("on_object_spawn", _item, global_position)

func set_radius(new_radius) -> void:
	radius = new_radius
	$CollisionShape2D.shape.radius = new_radius
