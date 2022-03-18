extends StaticBody2D



func _on_Area2D_body_entered(body):
	if $Area2D.get_overlapping_bodies().size() > 0:
		modulate.a = .7

func _on_Area2D_body_exited(body):
	if $Area2D.get_overlapping_bodies().size() == 0:
		modulate.a = 1.0
