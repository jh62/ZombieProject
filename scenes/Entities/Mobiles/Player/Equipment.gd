class_name PlayerEquipment extends Node2D

export var item : PackedScene

var primary_item setget set_primary_item
var secondary_item setget set_secondary_item

func _ready() -> void:
	if item != null:
		var t = item.instance()
		equip(t)

func equip(_item) -> void:	
	if has_item_equipped():
		var _old_item = get_item()

		if _old_item != _item && _item is Firearm && _old_item.get_weapon_type() == _item.get_weapon_type():
			_old_item.bullets += _item.bullets
			return

	unequip_all()
	
	_item.equipper = self.owner
	_item.light_mask = get_parent().get_node("Sprite").light_mask
	visible = true
	add_child(_item)

func set_primary_item(_item) -> void:
	primary_item = _item

func set_secondary_item(_item) -> void:
	secondary_item = _item
	
func equip_primary() -> void:
	equip(primary_item)

func equip_secondary() -> void:
	equip(secondary_item)
	
func unequip_all() -> void:
	for i in get_child_count():
		var _child = get_child(i)
		
		if _child.get_weapon_type() == Globals.WeaponNames.DISARMED:
			_child.call_deferred("queue_free")
			continue
		
		if _child is Firearm:
			primary_item = _child
		else:
			secondary_item = _child
			
		remove_child(_child)

func clear() -> void:
	for child in get_children():
		child.call_deferred("queue_free")

func has_item_equipped() -> bool:
	return get_child(0) != null

func get_item():
	return get_child(0)
