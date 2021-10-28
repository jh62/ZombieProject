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
	$Particles2D.one_shot = true

func _on_Projectile_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP_ZOMBIE):
		body.call_deferred("on_hit_by", self)
	$Timer.start()

func _on_Projectile_body_shape_entered(body_id, body, body_shape, local_shape):
	EventBus.emit_signal("play_sound_random_full", SOUNDS.ricochet, global_position)
	$Timer.start()

func _on_Timer_timeout():
	if $Particles2D.emitting:
		return
	queue_free()
