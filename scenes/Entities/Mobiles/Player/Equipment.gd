extends Node2D

export var item : PackedScene

func _ready() -> void:
	if item != null:
		var t = item.instance()
		equip(t)

func equip(_item : BaseItem) -> void:
	if has_item_equipped():
		var old_item := get_item()
		if old_item is Firearm:
			if _item.get_weapon_type() == old_item.get_weapon_type():
				_item.bullets += old_item.bullets
				print_debug(old_item.bullets)
		clear()

	_item.equipper = self.owner
	_item.light_mask = get_parent().light_mask
	visible = true
	add_child(_item)

func clear() -> void:
	for child in get_children():
		child.call_deferred("queue_free")

func has_item_equipped() -> bool:
	return get_child_count() > 0

func get_item() -> BaseItem:
	return get_child(0) as BaseItem

func _process(delta: float) -> void:
	pass
