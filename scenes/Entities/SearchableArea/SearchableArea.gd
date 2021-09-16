class_name SearchableArea extends Area2D

var searching := false setget, is_searching
var searched := false setget ,is_searched

func is_searched() -> bool:
	return searched

func is_searching() -> bool:
	return searching

func is_searchable() -> bool:
	return !is_searching() && !is_searched()

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

func _on_search_start() -> void:
	if !is_searchable():
		return
		
	searching = true
	
func _on_search_end() -> void:
	if !is_searchable():
		return
	
	searched = true
