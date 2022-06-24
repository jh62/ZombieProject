extends Pickable

func _ready():
	$Sprite.material.set("shader_param/hit_color", Color.green)

func on_picked_up_by(body) -> void:
	var player := body as Player
	var multiplier := .5 if (PlayerStatus.has_perk(Perk.PERK_TYPE.FIXXXER)) else .25
	var to_heal := player.hitpoints + (player.max_hitpoints * multiplier)
	player.set_hitpoints(to_heal)

	EventBus.emit_signal("on_request_update_health")
	EventBus.emit_signal("play_sound", get_picked_sound(), global_position)
	call_deferred("queue_free")
