class_name Globals extends Node

# SoundManager
signal play_sound_full(sound, position, pitch, db, max_distance)
signal play_sound(sound, position)
signal play_sound_random(sound, position)
signal play_sound_random_full(sound, position, pitch, db, max_distance)

const GROUP_PLAYER := "player"
const GROUP_ZOMBIE := "zombie"
