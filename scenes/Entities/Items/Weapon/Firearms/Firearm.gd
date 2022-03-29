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
#	yield(get_tree().create_timer(.1),"timeout") # leave it or bullets don't compute properly
#	reload()
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

			if !reload():
				return

			equipper.dir = Vector2.ZERO
			equipper.busy_time += reload_time
			EventBus.emit_signal("on_weapon_reloaded")

func _on_action_animation_started(_anim_name, _facing) -> void:
	match _anim_name:
		"shoot":
			if magazine == 0:
				in_use = false
				var snd = get_sound_dry()
				EventBus.emit_signal("play_sound_random", snd, global_position)
				return

			self.magazine -= 1

			if !Global.GameOptions.gameplay.discard_bullets:
				self.bullets -= 1

			equipper.vel += -equipper.facing * knockback

			var snd = get_sound_shoot()
			EventBus.emit_signal("play_sound_random", snd, global_position)

			EventBus.emit_signal("on_weapon_fired", global_position)
			emit_signal("on_use")

			var weapon_type = get_weapon_type()
			var spawn_bullet := true

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
						ray.enabled = true
						ray.cast_to = global_position.direction_to(get_global_mouse_position()) * global_position.distance_to(cc.global_position) * 1.25
						ray.force_raycast_update()

						if ray.is_colliding():
							var collider = ray.get_collider()
							if collider == cc:
								collider.kill()
								spawn_bullet = false

						ray.enabled = false

			if spawn_bullet:
				EventBus.emit_signal("on_bullet_spawn", global_position, damage, knockback, equipper.aiming, bullet_type)



func reload() -> bool:
	if bullets == 0:
		return false

	var to_reload := min(bullets, mag_size)

	if Global.GameOptions.gameplay.discard_bullets:
		self.bullets -= to_reload

	self.magazine = to_reload

	var snd = get_reload_sound()
	EventBus.emit_signal("play_sound_random", snd, global_position)

	return true
