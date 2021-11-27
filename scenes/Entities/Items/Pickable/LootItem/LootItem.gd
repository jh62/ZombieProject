class_name LootItem extends Pickable


func _ready():
	$Sprite.frame = randi() % ($Sprite.hframes * $Sprite.vframes)

func on_picked_up_by(body) -> void:
	EventBus.emit_signal("on_loot_pickedup", -1)
	.on_picked_up_by(body)
