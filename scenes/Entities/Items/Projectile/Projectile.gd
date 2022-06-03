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

const BodyHitSounds := [
	preload("res://assets/sfx/impact/bullet_body_1.wav"),
	preload("res://assets/sfx/impact/bullet_body_2.wav"),
	preload("res://assets/sfx/impact/bullet_body_3.wav"),
	preload("res://assets/sfx/impact/bullet_body_4.wav"),
]

onready var collision := $CollisionShape2D

var damage := 0.0
var knockback := 0.0

func _ready() -> void:
	pass

func _on_impact(body) -> void:
	if !is_inside_tree():
		return
		
	if !(body is Mobile):
		EventBus.emit_signal("spawn_decal", global_position)
		EventBus.emit_signal("play_sound_random_full", HITSOUNDS, global_position)
	else:
		EventBus.emit_signal("play_sound_random_full", BodyHitSounds, global_position)
		pass
		
	if body.has_method("on_hit_by"):
		body.call_deferred("on_hit_by", self)
		
	if get_parent() != null:
		get_parent().remove_child(self)

func _on_Projectile_body_entered(body: Node) -> void:
	_on_impact(body)

func _on_Projectile_body_shape_entered(body_id, body, body_shape, local_shape):
	_on_impact(body)

func _on_VisibilityTimer_timeout():
	if get_parent() != null:
		get_parent().remove_child(self)

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	if $VisibilityTimer.is_inside_tree():
		$VisibilityTimer.start(.15)
