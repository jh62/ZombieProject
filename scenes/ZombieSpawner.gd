extends Node2D

export var is_active := true
export var mob_max := 250
export var mob_group_max := 4
export var restart_delay := 30.0
export var spawn_delay_sec := 0.250
export var restartable := false

onready var n_timer := $Timer
onready var n_visible := $VisibilityNotifier2D

var tilemap : TileMap
var spawn_count := 0

func _ready() -> void:
	tilemap = get_parent().get_node("TileMap")
	n_timer.start(spawn_delay_sec)

func _spawn_mob(count := randi() % mob_group_max + 1) -> void:
	var areas := tilemap.get_node("AreaSpawns")
	for area in areas.get_children():
		var area_pos = area.global_position
		n_visible.global_position = area_pos
		yield(get_tree().create_timer(0.05),"timeout")

		if n_visible.is_on_screen(): # don't spawn zombies in player's view, it's not nice
			continue
		for i in count:
			var angle := rand_range(0.0, 2.0) * PI
			var direction = Vector2(cos(angle), sin(angle))
			var pos =  area_pos + direction * area.shape.radius

			spawn_count += 1
			EventBus.emit_signal("on_mob_spawn", pos)

		if spawn_count >= mob_max:
			return


func _on_Timer_timeout():
	if !is_active:
		n_timer.stop()
		return

	if spawn_count < mob_max:
		_spawn_mob()
		return

	if !restartable:
		n_timer.stop()
		set_process(false)
		return

	spawn_count = 0

	for z in get_tree().get_nodes_in_group(Globals.GROUP_ZOMBIE):
		if z.is_alive():
			spawn_count += 1

	n_timer.start(restart_delay)
	print_debug("restarted with {0} zombies alive".format({0:spawn_count}))
