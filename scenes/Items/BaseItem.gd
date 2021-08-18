class_name BaseItem extends Node

var texture_idle : Texture
var texture_run : Texture

func get_name() -> String:
	return ""

func get_texture(current_state) -> Texture:
	if current_state is IdleState:
		return texture_idle
	elif current_state is RunState:
		return texture_run
	return null
