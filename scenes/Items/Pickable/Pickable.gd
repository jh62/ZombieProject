class_name Pickable extends Area2D


func _ready() -> void:
	pass

func _on_Pickable_body_entered(body: Node) -> void:
	var item = preload("res://scenes/Items/Weapon/Pistol/Pistol.tscn").instance()
	EventBus.emit_signal("on_item_pickedup", item)
	queue_free()