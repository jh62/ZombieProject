class_name Projectile extends RigidBody2D

const SOUNDS := {
	"glass":[
		preload("res://assets/sfx/impact/bullet_glass_01.wav"),
		preload("res://assets/sfx/impact/bullet_glass_02.wav"),
		preload("res://assets/sfx/impact/bullet_glass_03.wav"),
		preload("res://assets/sfx/impact/bullet_glass_04.wav"),
	],
	"metal":[
		preload("res://assets/sfx/impact/bullet_metal_01.wav"),
		preload("res://assets/sfx/impact/bullet_metal_02.wav"),
		preload("res://assets/sfx/impact/bullet_metal_03.wav"),
		preload("res://assets/sfx/impact/bullet_metal_04.wav"),
	],
	"ricochet":[
		preload("res://assets/sfx/impact/ricochet_01.wav"),
		preload("res://assets/sfx/impact/ricochet_02.wav"),
		preload("res://assets/sfx/impact/ricochet_03.wav")
	]
}

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
	if body.is_in_group(Globals.GROUP_ZOMBIE):
		body.call_deferred("on_hit_by", self)
	queue_free()

func _on_Projectile_body_shape_entered(body_id, body, body_shape, local_shape):
	EventBus.emit_signal("play_sound_random_full", SOUNDS.ricochet, global_position)
	queue_free()
