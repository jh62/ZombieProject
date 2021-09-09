extends Node

onready var stream_2d := $Stream2d
onready var streams := $Normal

var idx := 0
var idx_2d := 0

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

func play_sound(stream : AudioStream, position = null, pitch_min_max := [1.0,1.0], db := 1.0) -> void:
	var audio_p

	if position != null:
		audio_p = get_audio_player_2d()
		audio_p.global_position = position
	else:
		audio_p = get_audio_player()

	audio_p.volume_db = db
	audio_p.pitch_scale = rand_range(pitch_min_max[0], pitch_min_max[1])
	audio_p.stream = stream
	audio_p.play()
