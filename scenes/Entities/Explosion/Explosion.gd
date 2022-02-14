class_name Explosion extends Area2D

signal explosion_complete

enum Type {
	BIG_1 = 0,
	BIG_2,
	BIG_3,
	SMALL_1,
	SMALL_2,
	HUGE
}

const SoundExplode := preload("res://assets/sfx/impact/fuelcan_explode.wav")
const SmallFlames := preload("res://scenes/Entities/FX/SmallFlames/SmallFlames.tscn")

const ExplosionTypes := {
	Type.BIG_1: "explode_1",
	Type.BIG_2: "explode_2",
	Type.BIG_3: "explode_3",
	Type.SMALL_1: "small_explode_1",
	Type.SMALL_2: "small_explode_2",
	Type.HUGE: "big_explosion",
}

func _ready():
	pass

func create_small_explosion(_radius := 16) -> void:
	var t := [Type.SMALL_1, Type.SMALL_2]
	t.shuffle()
	explode(t.front(), _radius)

func create_big_explosion(_radius := 32) -> void:
	var t := [Type.BIG_1, Type.BIG_2, Type.BIG_3]
	t.shuffle()
	explode(t.front(), _radius)

func create_huge_explosion(_radius := 48) -> void:
	explode(Type.HUGE, _radius)

func explode(explosion_type, _radius := 16) -> void:
	z_index += 1
#	$Light2D.enabled = true
	$AnimatedSprite.play(ExplosionTypes.get(explosion_type))
	$CollisionShape2D.shape.radius = _radius
	EventBus.emit_signal("play_sound_full", SoundExplode, global_position, rand_range(.9,1.1), 0.0, 500.0)

	yield(get_tree().create_timer(.1),"timeout")
	check_explosion()

	for i in range(14):
		var flames := SmallFlames.instance()
		flames.dir = Vector2(rand_range(-1,1),rand_range(-1,1))
		flames.speed = randf() * 5.0 + 3.0
		EventBus.emit_signal("on_object_spawn", flames, global_position)
		yield(get_tree(),"idle_frame")

func check_explosion() -> void:
	var bodies := get_overlapping_bodies()
	for b in bodies:
		if b.has_method("kill"):
			b.kill()
		elif b.has_method("explode"):
			b.explode()
#		yield(get_tree(),"idle_frame")
#		yield(get_tree().create_timer(0.015),"timeout")

func _process(delta):
	$Light2D.energy *= .96

func _on_AnimatedSprite_animation_finished():
	emit_signal("explosion_complete")
	queue_free()
