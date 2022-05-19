extends Map

onready var n_AreaExplosives := $Triggers/AreaExplosives
onready var n_Player := get_node("TileMap2/Entities/Mobs/Player")

func _ready():
	n_Player.connect("on_search_start", self, "_on_player_item_use")
	
	yield(get_tree().create_timer(0.5),"timeout")
	EventBus.emit_signal("update_objective", 0, false, false, "Get to the ship")
	
func _on_player_item_use(mob : Node2D) -> void:
	if mob in n_AreaExplosives.get_overlapping_bodies():
		n_AreaExplosives.on_activation(mob)
		return
