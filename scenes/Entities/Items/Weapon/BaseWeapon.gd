class_name BaseWeapon extends BaseItem

export var damage := 0.0
export var knockback := 0.0
export var bullets := 0 setget set_bullets
export var mag_size := 0
export var fire_rate := 0.0

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
				EventBus.emit_signal("play_sound_random", snd, Vector2.ZERO)
				return
			in_use = true
		EventBus.ActionEvent.RELOAD:
			emit_signal("on_use")
			if bullets / mag_size == 0:
				return
#			var to_reload = clamp(bullets - mag_size, 0, mag_size)
			self.bullets -= mag_size
			self.magazine = mag_size
			var snd = get_reload_sound()
			EventBus.emit_signal("play_sound_random", snd, Vector2.ZERO)

func _on_action_released(action_type : int, facing) -> void:
	if in_use:
		yield(anim_p,"animation_finished")
	in_use = false

func set_bullets(val : int) -> void:
	bullets = max(val, 0)

func set_magazine(val : int):
	magazine = clamp(val, 0, mag_size)

func update_animations() -> void:
	if equipper == null:
		return

	var state = equipper.fsm.current_state
	var facing = equipper.facing

	var state_name =  state.get_name()
	var facing_name = Mobile.get_facing_as_string(facing)
	var anim_name = "{0}_{1}".format({0:state_name,1:facing_name})

	if !anim_p.has_animation(anim_name):
		return

	self.flip_h = facing.x < 0

	if in_use:
		if anim_p.current_animation.begins_with("shoot"):
			return
		anim_name = "shoot_{0}".format({0:facing_name})
		anim_p.playback_speed = fire_rate
	else:
		anim_p.playback_speed = 1.0

	anim_p.play(anim_name)

func _on_action_animation_started(anim_name, facing) -> void:
	match anim_name:
		"shoot":
			if magazine == 0:
				var snd = get_sound_dry()
				EventBus.emit_signal("play_sound_random", snd, Vector2.ZERO)
				in_use = false
				return

			self.magazine -= 1
			self.bullets -= 1

			equipper.vel += -equipper.facing * damage * 10

			var snd = get_sound_shoot()
			emit_signal("on_use")

			EventBus.emit_signal("play_sound_random", snd, Vector2.ZERO)
			EventBus.emit_signal("on_bullet_spawn", equipper.global_position, damage, knockback)

