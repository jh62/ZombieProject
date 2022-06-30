class_name PlayerEquipment extends Node2D

export var item : PackedScene

var _primary_item setget set_primary_item
var _secondary_item setget set_secondary_item
var _current

func _ready() -> void:
	if item != null:
		var t = item.instance()
		equip(t)

func equip(_item) -> void:
	_current = _item
	
#	if _item is Firearm && _item != _primary_item:
#		set_primary_item(_item)
#		var _scene := PackedScene.new()
#		_scene.pack(_item)
#		PlayerStatus.set_weapon(_scene, 0, _item.bullets)
#	elif _item != _secondary_item:
#		set_secondary_item(_item)
#		var _scene := PackedScene.new()
#		_scene.pack(_item)
#		PlayerStatus.set_weapon(_scene, 1)
		
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
	_primary_item = _item

func set_secondary_item(_item) -> void:
	_secondary_item = _item
	
func equip_primary() -> void:
	equip(_primary_item)
	
	if _primary_item.is_magazine_empty() && _primary_item.has_bullets():
		_primary_item.reload()

func equip_secondary() -> void:
	equip(_secondary_item)
	
func unequip_all() -> void:
	for i in get_child_count():
		var _child = get_child(i)
		
		if _child.get_weapon_type() == Globals.WeaponNames.DISARMED:
			_child.call_deferred("queue_free")
			continue
			
		remove_child(_child)

func clear() -> void:
	for child in get_children():
		child.call_deferred("queue_free")

func has_item_equipped() -> bool:
	return get_child_count() > 0 && get_child(0) != null

func get_item():
	return get_child(0)
