extends Control

const MainScene := preload("res://scenes/Main.tscn")

onready var n_AnimPlayer := $AnimationPlayer
onready var n_Path2DFollow := $Path2D/PathFollow2D2

func _ready():
	var current_level = PlayerStatus.current_level
	n_AnimPlayer.play("path_{0}".format({0:current_level}))

func _process(delta):
	n_Path2DFollow.unit_offset = $Path2D/PathFollow2D.unit_offset

func _on_AnimationPlayer_animation_finished(anim_name : String):	
	if anim_name.begins_with("path"):
		n_AnimPlayer.play("transition")
	elif anim_name.begins_with("transition"):
		get_tree().change_scene_to(MainScene)
		call_deferred("queue_free")
	
