extends StaticBody2D

export var radius := 200.0
export var mob_max := 50
export var spawn_delay_sec := 1.5

var elapsed := 0.0
var spawn_count := 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed > spawn_delay_sec:
		elapsed = 0.0

		if spawn_count < mob_max:
			_spawn_mob()
		else:
			set_process(false)
			modulate = Color.black
			return

func _spawn_mob() -> void:
	var angle := rand_range(0.0, 2.0*PI)
	var direction = Vector2(cos(angle), sin(angle))
	var pos = global_position + direction * radius
	pos.x = clamp(pos.x, 0, 640)
	pos.y = clamp(pos.y, 0, 360)
	spawn_count += 1
	EventBus.emit_signal("on_mob_spawn", pos)
	