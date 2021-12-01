class_name Firearm extends BaseWeapon

export var bullets := 0 setget set_bullets
export var mag_size := 0

onready var n_Muzzle : Sprite = get_node("GunMuzzle")

var magazine := 0 setget set_magazine

# Virtual methods
func get_sound_dry():
	pass
func get_reload_sound():
	pass
func get_mag_icon():
	pass

func _ready():
	pass

func update_animations() -> void:
	.update_animations()
	n_Muzzle.flip_h = flip_h
	n_Muzzle.offset.x = -n_Muzzle.position.x * 2 if flip_h else 0

	if equipper.aiming:
		var f := Mobile.get_facing_as_string(equipper.facing)
		$AnimationPlayer.play("aim_" + f)

func set_bullets(val : int) -> void:
	bullets = max(val, 0)

func set_magazine(val : int):
	magazine = clamp(val, 0, mag_size)

func _on_action_pressed(action_type, facing) -> void:
	match action_type:
		EventBus.ActionEvent.USE:
			if magazine == 0:
				var snd = get_sound_dry()
				EventBus.emit_signal("play_sound_random", snd, Vector2.ZERO)
				return
			in_use = true
		EventBus.ActionEvent.RELOAD:
			emit_signal("on_use")
			if bullets / mag_size == 0:
				return
			self.bullets -= mag_size
			self.magazine = mag_size
			var snd = get_reload_sound()
			EventBus.emit_signal("play_sound_random", snd, Vector2.ZERO)

func _on_action_animation_started(_anim_name, _facing) -> void:
	._on_action_animation_started(_anim_name, _facing)

	match _anim_name:
		"shoot":
			if magazine == 0:
				var snd = get_sound_dry()
				EventBus.emit_signal("play_sound_random", snd, Vector2.ZERO)
				in_use = false
				return

			self.magazine -= 1
			self.bullets -= 1

			equipper.vel += -equipper.facing * knockback

			EventBus.emit_signal("on_bullet_spawn", global_position, damage, knockback)
