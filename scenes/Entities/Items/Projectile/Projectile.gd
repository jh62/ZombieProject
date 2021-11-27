class_name Projectile extends RigidBody2D

const HITSOUNDS := [
		preload("res://assets/sfx/impact/ricochet_01.wav"),
		preload("res://assets/sfx/impact/ricochet_02.wav"),
		preload("res://assets/sfx/impact/ricochet_03.wav")
]

const Decal := preload("res://scenes/Entities/FX/Decals/Decals.tscn")

onready var collision := $CollisionShape2D

var damage := 0.0
var knockback := 0.0

func _ready() -> void:
	if Input.is_action_pressed("aim"): # only headshots
		set_collision_mask_bit(2, false)

func _on_impact(body) -> void:
	if body.has_method("on_hit_by"):
		body.call_deferred("on_hit_by", self)

	var decal := Decal.instance()
	EventBus.emit_signal("on_object_spawn", decal, global_position)

	if !(body is Mobile):
		EventBus.emit_signal("play_sound_random_full", HITSOUNDS, global_position)

	call_deferred("queue_free")

func _on_Projectile_body_entered(body: Node) -> void:
	_on_impact(body)

func _on_Projectile_body_shape_entered(body_id, body, body_shape, local_shape):
	_on_impact(body)

func _on_VisibilityTimer_timeout():
	call_deferred("queue_free")

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	$VisibilityTimer.start(.15)
