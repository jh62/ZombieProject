extends Node

enum ActionEvent{
	USE,
	RELOAD
}

# Main signals
signal intro_finished
signal on_pause
signal on_unpause

# Player signals
signal action_pressed(action_name, facing)
signal action_released(action_name, facing)

# Pickable signals
signal on_item_pickedup(item)
signal on_loot_pickedup(items)

# Entity signals
signal on_bullet_spawn(position, direction, damage, aimed)
signal on_mob_spawn(position)
signal on_object_spawn(packed_scene, position)
signal on_fuelcan_explode

# Firearm signals
signal on_weapon_reloaded(weapon_name)

# SoundManager
signal play_sound_full(sound, position, pitch, db, max_distance)
signal play_sound(sound, position)
signal play_sound_random(sound, position)
signal play_sound_random_full(sound, position, pitch, db, max_distance)
