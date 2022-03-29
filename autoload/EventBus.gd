extends Node

enum ActionEvent{
	USE,
	RELOAD
}

# Main signals
signal intro_finished
signal on_pause
signal on_unpause

# HUD signals
signal on_request_update_health
signal on_tooltip(text)

# Player signals
signal action_pressed(action_name, facing)
signal action_released(action_name, facing)
signal on_player_death(player)

# Pickable signals
signal on_item_pickedup(item)
signal on_loot_pickedup()

# Entity signals
signal on_bullet_spawn(position, direction, damage, aimed, size)
signal on_mob_spawn(position)
signal on_object_spawn(packed_scene, position)
signal on_fuelcan_explode

# Fuelcan
signal fuel_pickedup(amount)
signal fuel_changed(amount)
signal fuel_emptied

# Firearm signals
signal on_weapon_reloaded
signal on_weapon_fired(position)

# SoundManager
signal play_sound_full(sound, position, pitch, db, max_distance)
signal play_sound(sound, position)
signal play_sound_random(sound, position)
signal play_sound_random_full(sound, position, pitch, db, max_distance)
signal play_music(music)
