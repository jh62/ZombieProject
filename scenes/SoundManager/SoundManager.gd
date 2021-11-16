extends Node2D

export var origin : NodePath

onready var music_player := $MusicPlayer
onready var audio_streams := $AudioStreams

var idx := 0

func _ready() -> void:
	EventBus.connect("play_sound_random_full", self, "_rplay_sound")
	EventBus.connect("play_sound_random", self, "_rplay_sound")
	EventBus.connect("play_sound_full", self, "_play_sound")
	EventBus.connect("play_sound", self, "_play_sound")
	EventBus.connect("intro_finished", self, "_on_intro_finished")

func _on_intro_finished() -> void:
	$MusicPlayer.play()

func get_audio_player() -> AudioStreamPlayer2D:
	var audio_p : AudioStreamPlayer2D

	while audio_p == null || audio_p.playing:
		idx = wrapi(idx + 1, 0, audio_streams.get_child_count())
		audio_p = audio_streams.get_child(idx)
	return audio_p

func _rplay_sound(stream_pool, position := Vector2.ZERO, pitch := rand_range(.95,1.05), db := 0.0, max_distance := 240.0) -> void:
	if stream_pool == null || stream_pool.size() == 0:
		return
	var stream = stream_pool[randi()%stream_pool.size()]
	_play_sound(stream, position, pitch, db, max_distance)

func _play_sound(stream : AudioStream, position = Vector2.ZERO, pitch := rand_range(.95,1.05), db := 0.0, max_distance := 240.0) -> void:
	if stream == null:
		return

	var audio_p = get_audio_player()

	audio_p.stream = stream
	audio_p.pitch_scale = pitch
	audio_p.volume_db = db
	audio_p.max_distance = max_distance
	audio_p.global_position = position if (position != Vector2.ZERO) else global_position
	audio_p.play()
