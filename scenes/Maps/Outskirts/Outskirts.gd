extends Map

onready var n_Player := get_node("TileMap2/Entities/Mobs/Player")

func _ready():
	n_Player.connect("on_search_start", self, "_on_player_item_use")
	EventBus.connect("intro_finished", self, "_on_intro_finished")
	
func _on_intro_finished() -> void:
	yield(get_tree().create_timer(1.5),"timeout")
	EventBus.emit_signal("update_objective", 0, false, true, "Find gas to fill your bike's fuel tank.")
	
func _on_player_item_use(mob : Node2D) -> void:
	pass

func _on_objective_completed(objective_id, _step):	
	match objective_id:
		0:
			pass
