class_name AreaSound extends Area2D

func get_footstep_sounds():
	pass

func _on_mob_footstep(mob : Mobile) -> void:
	if !(mob in get_overlapping_bodies()):
		return
	
	var sound
	var sound_pool = get_footstep_sounds()
	
	if mob.is_in_group(Globals.GROUP_PLAYER):
		sound = sound_pool.get(Globals.GROUP_PLAYER)
	else:
		sound = sound_pool.get(Globals.GROUP_ZOMBIE)
	EventBus.emit_signal("play_sound_random", sound, mob.global_position)
