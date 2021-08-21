tool
extends RigidBody2D

func _ready() -> void:
	$Particles2D.emitting = true


func _on_Projectile_body_entered(body: Node) -> void:
	linear_velocity = Vector2.ZERO
	if body is Mobile:
		body.call_deferred("on_hit", self)
