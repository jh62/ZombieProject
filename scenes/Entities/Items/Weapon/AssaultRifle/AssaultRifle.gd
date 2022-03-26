extends Firearm

const SOUNDS := {
	"shoot": [
		preload("res://assets/sfx/weapons/shoot_assault_1.wav"),
		preload("res://assets/sfx/weapons/shoot_assault_2.wav"),
		preload("res://assets/sfx/weapons/shoot_assault_3.wav"),
		preload("res://assets/sfx/weapons/shoot_assault_4.wav")
	],
	"dry": [
		preload("res://assets/sfx/weapons/dry_pistol_1.wav"),
	],
	"reload":[
		preload("res://assets/sfx/weapons/reload_pistol_1.wav"),
	]
}

func _ready() -> void:
	pass

func get_weapon_type():
	return Globals.WeaponNames.RIFLE

func get_icon() -> Texture:
	return preload("res://assets/res/weapon/icons/assault_icon.tres")

func get_mag_icon():
	return preload("res://assets/res/weapon/icons/riflemag_icon.tres")

func get_sound_dry():
	return SOUNDS.dry

func get_sound_shoot():
	return SOUNDS.shoot

func get_reload_sound():
	return SOUNDS.reload
