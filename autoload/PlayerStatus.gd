extends Node

var current_level := 1 setget set_current_level
var weapons := [null, null]
var perks := {}
var death_count := 0
var loot_count := 200
var precision_margin_error := 0.15
var max_hitpoints := 10

func _ready():
	var wep = preload("res://scenes/Entities/Items/Weapon/AssaultRifle/AssaultRifle.gd").new()
	wep.bullets = 200
	weapons[0] = wep

func set_current_level(_val) -> void:
	current_level = clamp(_val, 1, 4)

func set_weapon(_scene : PackedScene, _weapon_idx := 0, _bullets := 0) -> void:
	var _weapon := _scene.instance()
	_weapon.bullets = _bullets
	weapons[_weapon_idx] = _weapon

func get_weapon(_weapon_idx := 0):
	return weapons[_weapon_idx]

func get_cash() -> int:
	return loot_count * 25
