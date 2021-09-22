extends Node2D

export var origin : NodePath

var idx := 0
var idx_2d := 0
var last_played_ms := 0.0
var last_played_id := []

func _ready() -> void:
	EventBus.connect("play_sound_random_full", self, "_rplay_sound")
	EventBus.connect("play_sound_random", self, "_rplay_sound")
	EventBus.connect("play_sound_full", self, "_play_sound")
	EventBus.connect("play_sound", self, "_play_sound")

func get_audio_player():
	idx = wrapi(idx + 1, 0, get_child_count())
	var a := get_child(idx)
	return a

func _rplay_sound(stream_pool, position := Vector2.ZERO, pitch := rand_range(.95,1.05), db := 1.0, max_distance := 100.0) -> void:
	if stream_pool == null || stream_pool.size() == 0:
		print_debug("warning: no sound to play!")
		return
	var stream = stream_pool[randi()%stream_pool.size()]
	_play_sound(stream, position, pitch, db, max_distance)

func _play_sound(stream : AudioStream, position = Vector2.ZERO, pitch := rand_range(.95,1.05), db := 1.0, max_distance := 100.0) -> void:
	if stream == null:
		return

	var audio_p
	var stream_id := stream.get_instance_id()

	if stream_id in last_played_id:
		if OS.get_ticks_msec() - last_played_ms < 167:
			return
		last_played_id = []

	last_played_ms = OS.get_ticks_msec()
	last_played_id.append(stream.get_instance_id())
	audio_p = get_audio_player()

	if position != Vector2.ZERO:
		var dist : float = get_node(origin).global_position.distance_to(position)
		if dist > get_tree().root.get_visible_rect().size.x * .5:
			return
		var mul := db - dist / (max_distance * .1)
		db += mul

	audio_p.stream = stream
	audio_p.pitch_scale = pitch
	audio_p.volume_db = db
	audio_p.play()
