extends Node

enum ActionEvent{
	USE,
	RELOAD,
	USE_KEY
}

# Main signals
signal intro_finished
signal on_pause
signal on_unpause
signal on_escape
signal on_restart
signal on_quit

# Effect signals
signal create_shake(duration, frequency, amplitude, priority)

# HUD signals
signal on_request_update_health
signal on_tooltip(text)
signal update_objective(idx, completed, text, delay)
signal on_update_weapon_status()

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
signal spawn_decal(position)
signal spawn_blood(position)
signal mob_spawned(mob)
signal on_object_spawn(packed_scene, position)
signal on_fuelcan_explode

# Fuelcan
signal fuel_pickedup(amount)
signal fuel_changed(amount)
signal fuel_emptied

# Bike
signal on_bike_tank_full

# Firearm signals
signal on_weapon_reloaded(_weapon)
signal on_weapon_fired(position)

# SoundManager
signal play_sound_full(sound, position, pitch, db, max_distance)
signal play_sound(sound, position)
signal play_sound_random(sound, position)
signal play_sound_random_full(sound, position, pitch, db, max_distance)
signal play_music(music)
signal play_sound_no2d(sound, pitch, db)
signal play_sound_rand_no2d(sound_pool, pitch, db)

# Tilemap
signal tilemap_set_tile(cellv, id)
signal tilemap_set_tile_at(position, id)
