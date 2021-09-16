extends BaseWeapon

const SOUNDS := {
	"shoot": [
		preload("res://assets/sfx/weapons/shoot_pistol_1.wav"),
		preload("res://assets/sfx/weapons/shoot_pistol_2.wav"),
		preload("res://assets/sfx/weapons/shoot_pistol_3.wav"),
		preload("res://assets/sfx/weapons/shoot_pistol_4.wav")
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

func get_sound_dry():
	return SOUNDS.dry

func get_sound_shoot():
	return SOUNDS.shoot

func get_reload_sound():
	return SOUNDS.reload
