tool
extends StaticObject

export var full := false setget set_full

func _ready():
	pass

func set_full(_is_full : bool) -> void:
	full = _is_full
	$Sprite.frame = 1 if full else 0

