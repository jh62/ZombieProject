extends BaseWeapon

const sounds := {
	"shoot": preload("res://assets/sfx/weapons/shoot_pistol1.wav")
}

func _ready() -> void:
	magazine = clamp(bullets, 0, mag_size)

func _on_Pistol_on_action_activated() -> void:
	audio_p.pitch_scale = rand_range(1.0,1.1)
	audio_p.stream = sounds.shoot
	audio_p.play()

