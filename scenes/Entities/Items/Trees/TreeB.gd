class_name TreeEntity extends StaticBody2D

export var enabled := true setget set_enabled

func set_enabled(enabled : bool) -> void:
	$CollisionShape2D.disabled = !enabled

func set_light_mask(bit) -> void:
	$Tree.light_mask = bit

