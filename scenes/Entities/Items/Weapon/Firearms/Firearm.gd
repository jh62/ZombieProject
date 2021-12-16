class_name Firearm extends BaseWeapon

export var bullets := 0 setget set_bullets
export var mag_size := 0
export var reload_time := 2.0

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

	if !$AnimationPlayer.current_animation.begins_with("shoot"):
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
				EventBus.emit_signal("play_sound_random", snd, global_position)
				return
			in_use = true
		EventBus.ActionEvent.RELOAD:
			emit_signal("on_use")
			if bullets / mag_size == 0:
				return
			self.bullets -= mag_size
			self.magazine = mag_size

			equipper.dir = Vector2.ZERO
			equipper.busy_time += reload_time

			EventBus.emit_signal("on_weapon_reloaded", get_weapon_type())

			var snd = get_reload_sound()
			EventBus.emit_signal("play_sound_random", snd, global_position)

func _on_action_animation_started(_anim_name, _facing) -> void:
	match _anim_name:
		"shoot":
			if magazine == 0:
				var snd = get_sound_dry()
				EventBus.emit_signal("play_sound_random", snd, global_position)
				in_use = false
				return

			self.magazine -= 1
			self.bullets -= 1
			equipper.vel += -equipper.facing * knockback

			EventBus.emit_signal("on_bullet_spawn", global_position, damage, knockback, equipper.aiming)

			var snd = get_sound_shoot()
			emit_signal("on_use")
			EventBus.emit_signal("play_sound_random", snd, global_position)
