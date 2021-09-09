class_name Projectile extends RigidBody2D

onready var collision := $CollisionShape2D

var damage := 0.0
var knockback := 0.0

func _ready() -> void:
	$Particles2D.emitting = true

#func disable() -> void:
#	linear_damp = 10.0
#	set_collision_mask_bit(0, true)
#	set_collision_mask_bit(1, false)
#	set_collision_mask_bit(2, false)

func _on_Projectile_body_entered(body: Node) -> void:
	body.call_deferred("on_hit", self)
	queue_free()

func _on_Projectile_body_shape_entered(body_id, body, body_shape, local_shape):	
	queue_free()
