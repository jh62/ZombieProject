tool
extends StaticObject

export var type := 0 setget set_type

func set_type(_type : int) -> void:
	type = clamp(_type, 0, $Sprite.hframes * $Sprite.vframes)
	$Sprite.frame = type
