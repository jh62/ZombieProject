extends BaseWeapon

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
	]
}

func _ready() -> void:
	magazine = clamp(bullets, 0, mag_size)

func get_sound_dry():
	return sounds.dry[randi()%sounds.dry.size()]

func get_sound_shoot():
	return sounds.shoot[randi()%sounds.shoot.size()]

func get_reload_sound():
	return sounds.reload[randi()%sounds.reload.size()]
