extends Node

var current_level := 1 setget set_current_level

var weapons := {
	0:{
		"scene": preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn"),
		"bullets": 180
	},
	1:{
		"scene": preload("res://scenes/Entities/Items/Weapon/Disarmed/Disarmed.tscn")
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
var cash := 0 setget set_cash
var precision_margin_error := 0.15
var max_hitpoints := 10

var old_status := {
	"weapons": null,
	"perks": null,
	"death_count": 0,
	"cash": 0,
	"max_hitpoints": 10,
	"current_level": 1
}

func _ready():
	EventBus.connect("on_quit", self, "_reset")
	EventBus.connect("on_restart", self, "_reset")
	EventBus.connect("intro_finished", self, "_backup")
	
	match Global.GameOptions.gameplay.difficulty:
		Globals.Difficulty.NORMAL:
			weapons[0].bullets = 120
		Globals.Difficulty.HARD:
			weapons[0].bullets = 60
	
func _reset() -> void:
	var _status_backup := ConfigFile.new()
	var _uid := String(get_instance_id())
	var _error := _status_backup.load_encrypted_pass("res://{0}".format({0:_uid}), _uid)
	
	if _error != OK:
		print_debug("Error loading previous player status.")
		return
		
	weapons = _status_backup.get_value("PlayerStatus", "weapons")
	perks = _status_backup.get_value("PlayerStatus", "perks")
	current_level = _status_backup.get_value("PlayerStatus", "current_level")
	death_count = _status_backup.get_value("PlayerStatus", "death_count")
	cash = _status_backup.get_value("PlayerStatus", "cash")
	max_hitpoints = _status_backup.get_value("PlayerStatus", "max_hitpoints")

func _backup() -> void:
	var _uid := String(get_instance_id())
	var _status_backup = ConfigFile.new()
	
	_status_backup.set_value("PlayerStatus", "weapons", weapons)
	_status_backup.set_value("PlayerStatus", "perks", perks)
	_status_backup.set_value("PlayerStatus", "current_level", current_level)
	_status_backup.set_value("PlayerStatus", "death_count", death_count)
	_status_backup.set_value("PlayerStatus", "cash", cash)
	_status_backup.set_value("PlayerStatus", "max_hitpoints", max_hitpoints)
	
	_status_backup.save_encrypted_pass("res://{0}".format({0:_uid}), _uid)
	print_debug("Saved player status.")
		
func set_current_level(_val) -> void:
	current_level = clamp(_val, 1, 4)

func set_weapon(_scene, _weapon_idx := 0, _bullets := 0) -> void:
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
	
func set_cash(_value) -> void:
	cash = clamp(_value, 0, Global.MAX_CASH)

func get_cash() -> int:
	return cash

func has_perk(_perk_type) -> bool:
	return perks[_perk_type]
