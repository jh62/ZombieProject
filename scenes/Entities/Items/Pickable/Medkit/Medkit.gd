extends Pickable

func _ready():
	$Sprite.material.set("shader_param/hit_color", Color.green)

func on_picked_up_by(body) -> void:
	var player := body as Player
	var heal := player.max_hitpoints * .25
	player.set_hitpoints(heal)

	EventBus.emit_signal("on_request_update_health")
	EventBus.emit_signal("play_sound", get_picked_sound(), global_position)
	call_deferred("queue_free")
