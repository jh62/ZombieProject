extends Node2D

export var item : PackedScene

var primary_item setget set_primary_item
var secondary_item setget set_secondary_item

func _ready() -> void:
	if item != null:
		var t = item.instance()
		equip(t)

func equip(_item : BaseItem, _force_new := false) -> void:	
	if !(_force_new):
		if has_item_equipped():
			var old_item := get_item()
			if old_item is Firearm:
				if _item.get_weapon_type() == old_item.get_weapon_type():
					_item.bullets += old_item.bullets
			clear()
	else:
		clear()

	_item.equipper = self.owner
	_item.light_mask = get_parent().get_node("Sprite").light_mask
	visible = true
	add_child(_item)

func set_primary_item(_item) -> void:
	primary_item = _item

func set_secondary_item(_item) -> void:
	secondary_item = _item
	
func equip_primary() -> void:
	equip(primary_item, false)

func equip_secondary() -> void:
	equip(secondary_item, false)

func clear() -> void:
	for child in get_children():
		child.call_deferred("queue_free")

func has_item_equipped() -> bool:
	return get_child_count() > 0

func get_item() -> BaseItem:
	return get_child(0) as BaseItem

func _process(delta: float) -> void:
	pass
