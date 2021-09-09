extends Pickable


func _ready() -> void:
	pass

func _on_Pickable_body_entered(body: Node) -> void:
	var item = preload("res://scenes/Items/Weapon/Shotgun/Shotgun.tscn").instance()
	EventBus.emit_signal("on_item_pickedup", item)
	queue_free()
