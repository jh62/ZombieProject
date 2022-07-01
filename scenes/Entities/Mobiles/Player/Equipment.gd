class_name PlayerEquipment extends Node2D


export var item : PackedScene

onready var _disarmed := preload("res://scenes/Entities/Items/Weapon/Disarmed/Disarmed.tscn").instance()

var _primary_item setget set_primary_item
var _secondary_item setget set_secondary_item
var _current setget ,get_current

func _ready() -> void:
	if item != null:
		var t = item.instance()
		equip(t)

func get_current():
	return _current

func equip(_item) -> void:
	if _item is Firearm && _primary_item != _item && _primary_item.get_weapon_type() == _item.get_weapon_type():
		_item.bullets += _primary_item.bullets
		
	if _item.get_weapon_type() != Global.WeaponNames.DISARMED:
		var _scene := PackedScene.new()
		_scene.pack(_item)

		if _item is Firearm:
			set_primary_item(_item)
			PlayerStatus.set_weapon(_scene, 0, _item.bullets)
		else:
			set_secondary_item(_item)
			PlayerStatus.set_weapon(_scene, 1)	
			

	unequip_all()
	
	_current = _item
	
	_item.equipper = self.owner
	_item.light_mask = get_parent().get_node("Sprite").light_mask
	visible = true
	add_child(_item)	
	
	EventBus.emit_signal("on_update_weapon_status")

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

func disarm() -> void:
	equip(_disarmed)
	
func unequip_all() -> void:
	for _c in get_children():
		remove_child(_c)

func clear() -> void:
	for child in get_children():
		child.call_deferred("queue_free")

func has_item_equipped() -> bool:
	return get_child_count() > 0 && get_child(0) != null

func get_item():
	return get_child(0)
