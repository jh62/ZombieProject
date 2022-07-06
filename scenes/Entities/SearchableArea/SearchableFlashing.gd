extends Node2D

export var probability := 1.0 setget set_probabity

func _ready():
	if owner == null || probability < randf():
		call_deferred("queue_free")
		return
	
	var _material := preload("res://assets/res/fx/flashing_yellow.tres")
	_material.resource_local_to_scene = true
	get_parent().get_node("Sprite").material = _material
	
func set_probabity(_value) -> void:
	probability = clamp(_value, 0.0, 1.0)
