class_name Explosion extends Area2D

const SoundExplode := preload("res://assets/sfx/impact/fuelcan_explode.wav")

export var radius := 16

func _ready():
	$AnimatedSprite.play("explode")
	$Light2D.enabled = true
	$CollisionShape2D.shape.radius = radius
	EventBus.emit_signal("play_sound_full", SoundExplode, global_position, rand_range(.9,1.1), 1.0, 500.0)
	yield(get_tree().create_timer(.1),"timeout")
	check_explosion()

func check_explosion() -> void:
	var bodies := get_overlapping_bodies()
	for b in bodies:
		if b.has_method("kill"):
			b.kill()
		elif b.has_method("explode"):
			b.explode()

func _process(delta):
	$Light2D.energy *= .96

func _on_AnimatedSprite_animation_finished():
	queue_free()
