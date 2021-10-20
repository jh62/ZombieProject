tool
class_name SearchableArea extends Area2D

signal on_search_successful

export var radius := 10 setget set_radius
export var fill_time := 3.5

onready var progress_wheel := $CanvasLayer/ProgressWheel
onready var label := $CanvasLayer/Label

var searched_by : Node2D
var searching := false setget, is_searching
var looted := false setget ,is_looted

var loot := [
	preload("res://scenes/Entities/Items/Pickable/Pistol/PickablePistol.tscn"),
	preload("res://scenes/Entities/Items/Pickable/LootItem/LootItem.tscn")
]

func _ready():
	connect("on_search_successful", get_parent(), "on_search_successful")
	$CollisionShape2D.shape.radius = radius
	$CanvasLayer/ProgressWheel.fill_time = fill_time

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

	label.rect_position = get_global_transform_with_canvas().get_origin()
	label.rect_position.x -= label.rect_size.x * .5
	label.rect_position.y -= label.rect_size.y * 1.5

	body = body as Player
	body.connect("on_search_start", self, "_on_search_start")
	body.connect("on_search_end", self, "_on_search_end")
	label.visible = true

func _on_SearchableArea_body_exited(body : Node2D):
	if !body.is_in_group(Global.GROUP_PLAYER):
		return

	body = body as Player
	body.disconnect("on_search_start", self, "_on_search_start")
	body.disconnect("on_search_end", self, "_on_search_end")
	label.visible = false

	if searched_by == body:
		searched_by = null
		searching = false
		progress_wheel.stop()

func _on_search_start(mob) -> void:
	if !is_searchable():
		return

	if mob.fsm.current_state.get_name().begins_with("search"):
		return

	connect("on_search_successful", mob, "stop_search")
	mob.begin_search()

	searched_by = mob
	searching = true
	progress_wheel.rect_position = get_global_transform_with_canvas().get_origin()
	progress_wheel.rect_position -= progress_wheel.rect_size * .5
	progress_wheel.start()
	label.visible = false

func _on_search_end(mob) -> void:
	mob.stop_search()
	disconnect("on_search_successful", mob, "stop_search")

	searched_by = null
	searching = false
	progress_wheel.stop()
	label.visible = true

func _on_ProgressWheel_on_progress_complete():
	looted = true
	progress_wheel.stop()
	var item = loot[randi()%loot.size()]
	emit_signal("on_search_successful")
	EventBus.emit_signal("on_object_spawn", item, global_position)

func set_radius(new_radius) -> void:
	radius = new_radius
	$CollisionShape2D.shape.radius = new_radius
