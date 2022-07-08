class_name Projectile extends RigidBody2D

signal on_impact(bullet)
signal on_exit_screen(bullet)

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

func _on_impact(body) -> void:
	if body.is_in_group(Global.GROUP_HOSTILES):
		EventBus.emit_signal("play_sound_random_full", BodyHitSounds, global_position)
		body.call_deferred("on_hit_by", self)
		return
	
	EventBus.emit_signal("spawn_decal", global_position)
	EventBus.emit_signal("play_sound_random_full", HITSOUNDS, global_position)
	yield(get_tree().create_timer(0.15),"timeout")
	emit_signal("on_impact", self)

func _on_Projectile_body_entered(body: Node) -> void:
	_on_impact(body)

func _on_Projectile_body_shape_entered(body_id, body, body_shape, local_shape):
	_on_impact(body)

func _on_VisibilityTimer_timeout():
	if get_parent() != null:
		get_parent().remove_child(self)
		
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	emit_signal("on_exit_screen", self)
