extends Node

var current_level := 1 setget set_current_level

var weapons := {
	0:{
		"scene": null,
		"bullets": 0
	},
	1:{
		"scene": null
	}
}

var perks := {
	Perk.PERK_TYPE.ADRENALINE: false,
	Perk.PERK_TYPE.FAST_RELOAD: false,
	Perk.PERK_TYPE.FIXXXER: false,
	Perk.PERK_TYPE.FREE_FIRE: false,
	Perk.PERK_TYPE.HOLLYWOOD_MAG: false,
	Perk.PERK_TYPE.MOONWALKER: false,
	Perk.PERK_TYPE.SHADOW_DANCER: false,
	Perk.PERK_TYPE.TOUGH_GUY: false,
}

var death_count := 0
var loot_count := 50 setget set_loot_count
var precision_margin_error := 0.15
var max_hitpoints := 10

func _ready():	
	if has_perk(Perk.PERK_TYPE.TOUGH_GUY):
		max_hitpoints *= 1.5
	
	match Global.GameOptions.gameplay.difficulty:
		Globals.Difficulty.EASY:
			PlayerStatus.set_weapon(
				preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn"),
				0,
				220
			)
			PlayerStatus.set_weapon(
				preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Sword/Sword.tscn"),
				1,
				220
			)
		Globals.Difficulty.NORMAL:
			PlayerStatus.set_weapon(
				preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn"),
				0,
				160
			)
			PlayerStatus.set_weapon(
				preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Sword/Sword.tscn"),
				1,
				220
			)
		Globals.Difficulty.HARD:
			PlayerStatus.set_weapon(
				preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn"),
				0,
				10
			)
			PlayerStatus.set_weapon(
				preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Sword/Sword.tscn"),
				1,
				220
			)

func set_current_level(_val) -> void:
	current_level = clamp(_val, 1, 4)

func set_weapon(_scene, _weapon_idx := 0, _bullets := 0) -> void:
	var _weapon = _scene
	
	match _weapon_idx:
		0:
			weapons[_weapon_idx].bullets = _bullets
			continue
		_:
			weapons[_weapon_idx].scene = _scene

func get_weapon(_weapon_idx := 0) -> BaseWeapon:
	var _weapon = weapons[_weapon_idx]
	
	if _weapon.scene == null:
		return null
	
	var _instance = _weapon.scene.instance()
			
	if _instance is Firearm:
		_instance.bullets = _weapon.bullets
		
	return _instance
	
func set_loot_count(_value) -> void:
	loot_count = clamp(_value * Global.LOOT_MULTIPLIER, 0, Global.MAX_LOOT_COUNT)

func get_cash() -> int:
	return loot_count * Global.LOOT_MULTIPLIER

func has_perk(_perk_type) -> bool:
	return perks[_perk_type]
