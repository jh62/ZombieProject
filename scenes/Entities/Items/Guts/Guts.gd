extends RigidBody2D

export var decay_time := 1.0

var decay_time_elapsed := 0.0

func _ready():
	var impulse := rand_range(50.0,150.0)
	var angle := rand_range(0.0, 2.0) * PI
	var direction = Vector2(cos(angle), sin(angle))
	apply_impulse(Vector2.ZERO, Vector2(impulse * direction.x, impulse * direction.y))
	angular_velocity = impulse

	var scale := clamp(randf(), .96, 1.0)
	var frames = $Sprite.hframes * $Sprite.vframes
	$Sprite.frame = randi() % frames
	$Sprite.scale = Vector2(scale,scale)

func _process(delta):
	if decay_time_elapsed >= decay_time:
		$Sprite.modulate.a *= .997
		if $Sprite.modulate.a < .01:
			call_deferred("queue_free")
		return
	decay_time_elapsed += delta
