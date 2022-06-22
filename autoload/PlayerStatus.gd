extends Node

var current_level := 1 setget set_current_level
var weapons := [null, null]
var perks := []
var death_count := 0
var loot_count := 10
var precision_margin_error := 0.15
var max_hitpoints := 10

func _ready():
	match Global.GameOptions.gameplay.difficulty:
		Globals.Difficulty.EASY:
			PlayerStatus.set_weapon(
				preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn"),
				0,
				220
			)
		Globals.Difficulty.NORMAL:
			PlayerStatus.set_weapon(
				preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn"),
				0,
				160
			)
		Globals.Difficulty.HARD:
			PlayerStatus.set_weapon(
				preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn"),
				0,
				120
			)

func set_current_level(_val) -> void:
	current_level = clamp(_val, 1, 4)

func set_weapon(_scene : PackedScene, _weapon_idx := 0, _bullets := 0) -> void:
	var _weapon := _scene.instance()
	
	if _weapon is Firearm:
		_weapon.bullets = _bullets
		
	weapons[_weapon_idx] = _weapon

func get_weapon(_weapon_idx := 0):
	return weapons[_weapon_idx]

func get_cash() -> int:
	return loot_count * 25
