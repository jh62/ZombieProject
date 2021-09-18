class_name SearchableArea extends Area2D

signal on_search_successful

onready var progress_wheel := $ProgressWheel

var searched_by : Node2D
var searching := false setget, is_searching
var looted := false setget ,is_looted

var loot := [
	preload("res://scenes/Entities/Items/Pickable/Pistol/Pistol.tscn"),
	preload("res://scenes/Entities/Items/Pickable/LootItem/LootItem.tscn")
]

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

func _on_SearchableArea_body_exited(body : Node2D):
	if !body.is_in_group(Global.GROUP_PLAYER):
		return
		
	body = body as Player
	body.disconnect("on_search_start", self, "_on_search_start")
	body.disconnect("on_search_end", self, "_on_search_end")
	
	if searched_by == body:
		searched_by = null
		searching = false
		progress_wheel.stop()

func _on_search_start(mob) -> void:
	if !is_searchable():
		return
	
	searched_by = mob
	searching = true
	progress_wheel.start()
	
func _on_search_end(mob) -> void:
	if !is_searchable():
		return
	
	searched_by = null
	searching = false
	progress_wheel.stop()

func _on_ProgressWheel_on_progress_complete():
	looted = true
	progress_wheel.stop()
	var item = loot[randi()%loot.size()]
	emit_signal("on_search_successful")
	EventBus.emit_signal("on_object_spawn", item, global_position)
