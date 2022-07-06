class_name LootItem extends Pickable

onready var value := randi() % 25 + 5

func _ready():
	overlay_text = "${0}".format({0:value})
	n_Sprite.frame = randi() % (n_Sprite.hframes * n_Sprite.vframes)

func on_picked_up_by(body : Node2D) -> void:
	PlayerStatus.cash += value
	.on_picked_up_by(body)
	EventBus.emit_signal("on_loot_pickedup")
