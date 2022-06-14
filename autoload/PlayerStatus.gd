extends Node

var current_level := 1 setget set_current_level
var weapons := [null, null] setget ,get_weapon
var perks := {}
var death_count := 0
var loot_count := 0
var precision_margin_error := 0.15
var max_hitpoints := 10

func set_current_level(_val) -> void:
	current_level = clamp(_val, 1, 4)

func set_weapon(_scene : PackedScene, _weapon_idx := 0, _bullets := 0) -> void:
	var _weapon := _scene.instance()
	_weapon.bullets = _bullets
	weapons[_weapon_idx] = _weapon

func get_weapon(_weapon_idx := 0):
	return weapons[_weapon_idx]
