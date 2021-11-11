class_name LootItem extends Pickable

func _ready():
	$Sprite.frame = randi() % ($Sprite.hframes * $Sprite.vframes)

func _process(delta):
	if picked:
		position = position.linear_interpolate(Vector2.ZERO, delta)

func on_picked_up_by(body) -> void:
	EventBus.emit_signal("on_loot_pickedup", -1)
