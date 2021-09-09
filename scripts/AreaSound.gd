class_name AreaSound extends Area2D

export var footstep_db := -7.5

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
	
	SoundManager.play_sound_pool(sound, mob.global_position, rand_range(.9,1.1), footstep_db)
