extends Firearm

const sounds := {
	"shoot": [
		preload("res://assets/sfx/weapons/shoot_shotgun_1.wav"),
		preload("res://assets/sfx/weapons/shoot_shotgun_2.wav"),
		preload("res://assets/sfx/weapons/shoot_shotgun_3.wav")
	],
	"dry": [
		preload("res://assets/sfx/weapons/dry_shotgun_1.wav"),
	],
	"reload":[
		preload("res://assets/sfx/weapons/reload_shotgun_1.wav"),
		preload("res://assets/sfx/weapons/reload_shotgun_2.wav"),
		preload("res://assets/sfx/weapons/reload_shotgun_3.wav"),
	]
}

func _ready() -> void:
	pass

func get_weapon_type():
	return Globals.WeaponNames.SHOTGUN

func get_icon() -> Texture:
	return preload("res://assets/res/weapon/icons/shotgun_icon.tres")

func get_mag_icon():
	return preload("res://assets/res/weapon/icons/slug_icon.tres")

func get_sound_dry():
	return sounds.dry

func get_sound_shoot():
	return sounds.shoot

func get_reload_sound():
	return sounds.reload
