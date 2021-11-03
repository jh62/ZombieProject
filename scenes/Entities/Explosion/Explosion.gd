class_name Explosion extends Area2D

const SoundExplode := preload("res://assets/sfx/impact/fuelcan_explode.wav")

var exploded := false

func _ready():
	$AnimatedSprite.play("explode")
	EventBus.emit_signal("play_sound_full", SoundExplode, global_position, rand_range(.9,1.1), 1.0, 500.0)

func _process(delta):
	if exploded:
		set_process(false)
		return
	exploded = true
	var bodies := get_overlapping_bodies()

	for b in bodies:
		if b.has_method("kill"):
			b.vel = global_position.direction_to(b.global_position) * 10.0
			b.kill()
		elif b.has_method("explode"):
			b.explode()

func _on_AnimatedSprite_animation_finished():
#	queue_free()
	pass
