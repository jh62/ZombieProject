class_name Firearm extends BaseWeapon

export var bullets := 0 setget set_bullets
export var mag_size := 0
export var reload_time := 2.0
export(Projectile.Type) var bullet_type := Projectile.Type.BULLET

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
	var snd = get_reload_sound()
	EventBus.emit_signal("play_sound_random", snd, global_position)

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

func is_obstructed() -> bool:
	n_raycast.enabled = true
	n_raycast.cast_to = equipper.facing * 12.0
	n_raycast.force_raycast_update()
	var is_colliding := n_raycast.is_colliding()
	n_raycast.enabled = false
	return is_colliding

func _on_action_pressed(action_type, facing) -> void:
	if !is_inside_tree():
		in_use = false
		return
		
	match action_type:
		EventBus.ActionEvent.USE:
			if is_obstructed():
				return

			if !has_bullets():
				var snd = get_sound_dry()
				EventBus.emit_signal("play_sound_random", snd, global_position)
				return
				
			in_use = true
		EventBus.ActionEvent.RELOAD:
			emit_signal("on_use")

			if !reload():
				return

			equipper.dir = Vector2.ZERO
			equipper.busy_time += reload_time
			EventBus.emit_signal("on_weapon_reloaded", get_weapon_type())

func _on_action_animation_finished(_anim_name, _facing) -> void:
	match _anim_name:
		"shoot":
			if is_obstructed():
				in_use = false
				return

			if !has_bullets():
				in_use = false
				var snd = get_sound_dry()
				EventBus.emit_signal("play_sound_random", snd, global_position)
				return

func _on_action_animation_started(_anim_name, _facing) -> void:
	match _anim_name:
		"shoot":
			if !has_bullets():
				in_use = false
				var snd = get_sound_dry()
				EventBus.emit_signal("play_sound_random", snd, global_position)
				return
				
			if !PlayerStatus.has_perk(Perk.PERK_TYPE.HOLLYWOOD_MAG):
				self.magazine -= 1

			if !Global.GameOptions.gameplay.discard_bullets:
				
				if PlayerStatus.has_perk(Perk.PERK_TYPE.FREE_FIRE) && get_weapon_type() == Globals.WeaponNames.PISTOL:
					pass
				else:
					self.bullets -= 1

			equipper.vel += -equipper.facing * knockback

			var spawn_bullet := true

			if equipper.aiming:
				match bullet_type:
					Projectile.Type.SHELL:
						pass
					_:
						var space = get_world_2d().direct_space_state
						var mouse_pos := get_global_mouse_position()

						var collisions = space.intersect_point(mouse_pos, 1, [], 512, false, true)

						if !collisions.empty():
							var cc = collisions[0].collider.get_parent()
							var ray : RayCast2D = equipper.ray

							ray.cast_to = get_global_mouse_position() - equipper.position
							ray.force_raycast_update()
							if ray.is_colliding():
								var collider = ray.get_collider().get_parent()
								if collider == cc:
									
									if collider.has_method("on_headshot"):
										collider.call("on_headshot")
									else:
										collider.kill()
									spawn_bullet = false
									EventBus.emit_signal("create_shake", .05, 120, 4, 0)

#							ray.enabled = false

			if spawn_bullet:
				var _bullet_pos = equipper.global_position
				var _equipper_facing = equipper.facing.normalized().round()

				if _equipper_facing.x != 0:
					_bullet_pos.x += _equipper_facing.x * 10
				if _equipper_facing.y != 0:
					_bullet_pos.y += _equipper_facing.y * 10

				EventBus.emit_signal("on_bullet_spawn", _bullet_pos, damage, knockback, equipper.aiming, bullet_type)

			var snd = get_sound_shoot()
			EventBus.emit_signal("play_sound_random", snd, global_position)

			EventBus.emit_signal("on_weapon_fired", global_position)
			emit_signal("on_use")

func has_bullets() -> bool:
	return !is_magazine_empty() && bullets > 0

func is_magazine_empty() -> bool:
	return magazine == 0

func reload(_quiet := false) -> bool:
	if bullets == 0:
		return false
	
	if magazine == mag_size:
		return false

	var to_reload := min(bullets, mag_size)

	if Global.GameOptions.gameplay.discard_bullets:
		self.bullets -= to_reload

	self.magazine = to_reload
	
	if !(_quiet):
		var snd = get_reload_sound()
		EventBus.emit_signal("play_sound_random", snd, global_position)

	return true
