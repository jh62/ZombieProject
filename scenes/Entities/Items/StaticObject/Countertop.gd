extends StaticObject

export var sprite_idx := 0 setget set_sprite_idx

func set_sprite_idx(_val) -> void:
	sprite_idx = clamp(_val, 0, $Sprite.hframes * $Sprite.vframes)
	$Sprite.frame = sprite_idx
