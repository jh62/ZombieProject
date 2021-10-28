extends Pickable

func _ready() -> void:
	pass

func _on_Pickable_body_entered(body: Node) -> void:
	var item = preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn")
#	var item = preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/MeleeWeapon.tscn")
	EventBus.emit_signal("on_item_pickedup", item.instance())
	queue_free()
