extends StaticObject

onready var n_SpriteTop := $SpriteTop

func _on_body_entered(body : Node2D):
	n_SpriteTop.self_modulate.a = .65

func _on_body_exited(body):
	if n_Area2d.get_overlapping_bodies().size() == 0:
		n_SpriteTop.self_modulate.a = 1.0
