extends Node2D

export var active := true
export var mob_max := 100
export var mob_group_max := 4
export var spawn_delay_sec := 30.0
export var restart_delay := 15.0
export var restartable := false

onready var n_visible := $VisibilityNotifier2D

var tilemap : TileMap

var elapsed := 0.0
var spawn_count := 0

func _ready() -> void:
	tilemap = get_parent()
	if active:
#		yield(get_tree().create_timer(.15),"timeout")
		_spawn_mob()

func _process(delta: float) -> void:
	if !active:
		return

	elapsed += delta

	if elapsed < 0.0:
		return

	if elapsed > spawn_delay_sec:
		elapsed = 0.0

		if spawn_count < mob_max:
			_spawn_mob()
		else:
			if !restartable:
				set_process(false)
				return
			elapsed = -restart_delay

func _spawn_mob(count := randi() % mob_group_max + 1) -> void:
	var areas := tilemap.get_node("AreaSpawns")
	for area in areas.get_children():
		var area_pos = area.global_position
		n_visible.global_position = area_pos
		yield(get_tree().create_timer(0.18),"timeout")
		if n_visible.is_on_screen(): # don't spawn zombies in player's view, it's not nice
			print_debug("zombie visible")
			continue
		for i in count:
			var angle := rand_range(0.0, 2.0) * PI
			var direction = Vector2(cos(angle), sin(angle))
			var pos =  area_pos + direction * area.shape.radius
			spawn_count += 1
			EventBus.emit_signal("on_mob_spawn", pos)

		if spawn_count >= mob_max:
			return
