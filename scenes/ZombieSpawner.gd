extends Node2D

export var is_active := true setget set_active
export var mob_max := 250
export var mob_group_max := 4
export var restart_delay := 30.0
export var spawn_delay_sec := 0.5
export var restartable := false

onready var n_timer := $Timer

onready var map : Map
var spawn_count := 0

func _ready() -> void:
	yield(get_tree().create_timer(0.15),"timeout")
	map = get_parent().n_MapManager.get_map()
	
	if Global.DEBUG_MODE:
		print_debug("Spawning max {0}".format({0:mob_max}))

	if is_active:
		n_timer.start(spawn_delay_sec)

func _spawn_mob(count := randi() % mob_group_max + 1) -> void:
	var areas = map.n_SpawnAreas
	for area in areas.get_children():
		var area_pos = area.global_position

		if area.is_on_screen(): # don't spawn zombies in player's view, it's not nice
			continue
			
		for i in count:
			var angle := rand_range(0.0, 2.0) * PI
			var direction = Vector2(cos(angle), sin(angle))
			var pos =  area_pos + direction * area.rect.size.x

			spawn_count += 1
			EventBus.emit_signal("on_mob_spawn", pos)

			if spawn_count >= mob_max:
				return


func _on_Timer_timeout():
	if spawn_count < mob_max:
		_spawn_mob()
		return

	if !restartable:
		n_timer.stop()
		set_process(false)
		return

	spawn_count = 0

	for z in get_tree().get_nodes_in_group(Globals.GROUP_HOSTILES):
		if z.is_alive():
			spawn_count += 1

	n_timer.stop()
	n_timer.start(restart_delay)

func set_active(active : bool) -> void:
	is_active = active

	if !is_inside_tree():
		return

	if is_active && n_timer.is_stopped():
		n_timer.start()
		return

	if !is_active:
		if !n_timer.is_stopped():
			n_timer.stop()

		for m in get_tree().get_nodes_in_group(Global.GROUP_HOSTILES):
			m.call_deferred("queue_free")
