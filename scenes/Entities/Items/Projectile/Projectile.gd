class_name Projectile extends RigidBody2D

enum Type {
	BULLET = 0,
	SHELL
}

const HITSOUNDS := [
	preload("res://assets/sfx/impact/ricochet_1.wav"),
	preload("res://assets/sfx/impact/ricochet_2.wav"),
	preload("res://assets/sfx/impact/ricochet_3.wav")
]

onready var collision := $CollisionShape2D

var damage := 0.0
var knockback := 0.0

func _ready() -> void:
	pass

func _on_impact(body) -> void:
	if body.has_method("on_hit_by"):
		body.call_deferred("on_hit_by", self)
			
	if !(body is Mobile):
		EventBus.emit_signal("spawn_decal", global_position)
		EventBus.emit_signal("play_sound_random_full", HITSOUNDS, global_position)

	if get_parent() != null:
		get_parent().remove_child(self)
		print_debug("removed")
#	print_debug(get_parent())
#	call_deferred("queue_free")

func _on_Projectile_body_entered(body: Node) -> void:
	_on_impact(body)

func _on_Projectile_body_shape_entered(body_id, body, body_shape, local_shape):
	_on_impact(body)

func _on_VisibilityTimer_timeout():
#	call_deferred("queue_free")
	pass

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	if $VisibilityTimer.is_inside_tree():
		$VisibilityTimer.start(.15)
