class_name StaticObject extends StaticBody2D

onready var n_sprite := $Sprite

func _ready():
	yield(get_tree().create_timer(.25),"timeout")
	var poly = $CollisionShape.get_polygon()
	$Area2D/CollisionShapeArea.set_polygon(poly)
	$Area2D.position += Vector2.UP * 4

func _on_body_entered(body):
	n_sprite.self_modulate.a = .77

func _on_body_exited(body):
	n_sprite.self_modulate.a = 1.0
