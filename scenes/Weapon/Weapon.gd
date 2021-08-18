class_name Weapon extends Node2D

onready var sprite := get_node("Sprite")

func set_animation(anim_name : String, anim_dir : String, hframes : int, vframes : int) -> void:
	pass

func update_frame(frame : int, hframes : int, vframes : int, flip_h : bool) -> void:
	pass
