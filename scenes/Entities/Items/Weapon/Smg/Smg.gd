extends Firearm

const SOUNDS := {
	"shoot": [
		preload("res://assets/sfx/weapons/shoot_smg_1.wav"),
		preload("res://assets/sfx/weapons/shoot_smg_2.wav"),
		preload("res://assets/sfx/weapons/shoot_smg_3.wav"),
		preload("res://assets/sfx/weapons/shoot_smg_4.wav")
	],
	"dry": [
		preload("res://assets/sfx/weapons/dry_pistol_1.wav"),
	],
	"reload":[
		preload("res://assets/sfx/weapons/reload_pistol_1.wav"),
	]
}

func _ready() -> void:
	magazine = clamp(bullets, 0, mag_size)

func get_weapon_type():
	return Globals.WeaponNames.SMG

func get_icon() -> Texture:
	return preload("res://assets/res/weapon/icons/smg_icon.tres")

func get_mag_icon():
	return preload("res://assets/res/weapon/icons/bullet_icon.tres")

func get_sound_dry():
	return SOUNDS.dry

func get_sound_shoot():
	return SOUNDS.shoot

func get_reload_sound():
	return SOUNDS.reload
