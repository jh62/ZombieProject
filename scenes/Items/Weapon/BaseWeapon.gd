class_name BaseWeapon extends BaseItem

export var damage := 0.0
export var knockback := 0.0
export var bullets := 0
export var mag_size := 0
export var fire_rate := 1.0

var magazine := 0 setget set_magazine

func get_sound_dry():
	pass

func get_sound_shoot():
	pass

func get_reload_sound():
	pass

func _on_action_pressed(action_type, facing) -> void:
	match action_type:
		EventBus.ActionEvent.USE:
			if magazine == 0:
				var snd = get_sound_dry()
				SoundManager.play_sound(snd)
				return
			in_use = true
		EventBus.ActionEvent.RELOAD:
			if bullets == 0:
				return
			var to_reload = clamp(bullets - mag_size, 0, mag_size)
			bullets -= to_reload
			magazine = to_reload
			var snd = get_sound_dry()
			SoundManager.play_sound(get_reload_sound())

func _on_action_released(action_type : int, facing) -> void:
	if in_use:
		yield(anim_p,"animation_finished")
	in_use = false

func set_magazine(val : int):
	magazine = clamp(val, 0, mag_size)

func update_animations() -> void:
	if equipper == null:
		return

	var state = equipper.fsm.current_state
	var facing = equipper.facing

	var anim_name =  state.get_name()
	var anim_dir = Mobile.get_facing_as_string(facing)
	self.flip_h = facing.x < 0

	if in_use:
		if anim_p.current_animation.begins_with("shoot"):
			return
		anim_name = "shoot"
		anim_p.playback_speed = fire_rate
	else:
		anim_p.playback_speed = 1.0

	anim_p.play("{0}_{1}".format({0:anim_name,1:anim_dir}))

func _on_action_started(anim_name, facing) -> void:
	match anim_name:
		"shoot":
			if magazine == 0:
				var snd = get_sound_dry()
				SoundManager.play_sound(snd)
				in_use = false
				return

			magazine -= 1

			equipper.vel += -equipper.facing * damage * 10

			var snd = get_sound_shoot()
			SoundManager.play_sound(snd, equipper.global_position)

			EventBus.emit_signal("on_bullet_spawn", equipper.global_position, damage, knockback)

