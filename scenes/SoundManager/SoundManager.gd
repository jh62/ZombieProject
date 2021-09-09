extends Node

onready var stream_2d := $Stream2d
onready var streams := $Normal

var idx := 0
var idx_2d := 0
var last_played_ms := 0.0
var last_played_id := []

func _ready() -> void:
	pass

func get_audio_player():
	idx = wrapi(idx + 1, 0, streams.get_child_count())
	var a := streams.get_child(idx)
	return a

func get_audio_player_2d():
	idx_2d = wrapi(idx_2d + 1, 0, stream_2d.get_child_count())
	var a := stream_2d.get_child(idx_2d)
	return a

func play_sound_pool(stream_pool, position := Vector2.ZERO, pitch := rand_range(.95,1.05), db := 1.0) -> void:
	var stream = stream_pool[randi()%stream_pool.size()]
	play_sound(stream, position, pitch, db)

func play_sound(stream : AudioStream, position = Vector2.ZERO, pitch := rand_range(.95,1.05), db := 1.0) -> void:
	if stream == null:
		return
		
	var audio_p
	var stream_id := stream.get_instance_id()
	
	if stream_id in last_played_id:
		if OS.get_ticks_msec() - last_played_ms < 50.0:
			return
		last_played_id = []
		
	last_played_ms = OS.get_ticks_msec()
	last_played_id.append(stream.get_instance_id())
	
	if position != Vector2.ZERO:
		audio_p = get_audio_player_2d()
		audio_p.global_position = position
	else:
		audio_p = get_audio_player()
	
	audio_p.stream = stream
	audio_p.pitch_scale = pitch
	audio_p.volume_db = db
	audio_p.play()
