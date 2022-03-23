extends NinePatchRect

var minimap_icon

onready var player_marker := $PlayerMarker
onready var mob_marker := $MobMarker

var n_player : Node2D
var zoom = 0.25
var grid_scale
var markers := {}

func _ready():
	player_marker.rect_position = rect_size / 2
	grid_scale = rect_size / (get_viewport_rect().size * zoom)

func _on_mob_spawned(mob : Node2D) -> void:
	add_to_group("minimap_mob")
	var new_marker = mob_marker.duplicate()
	add_child(new_marker)
	new_marker.show()
	markers[mob] = new_marker

func _process(delta):
	if !n_player || markers.empty():
		return
#	player_marker.rotation = n_player.rotation + PI/2

	for mob in markers.keys():
		var mob_marker = markers[mob]

		if !mob.is_alive():
			mob_marker.call_deferred("queue_free")
			markers.erase(mob)
			continue

		var obj_pos = (mob.position - n_player.position) * grid_scale + rect_size / 2
		obj_pos.x = clamp(obj_pos.x, 0, rect_size.x)
		obj_pos.y = clamp(obj_pos.y, 0, rect_size.y)
		mob_marker.rect_position = obj_pos

		if get_rect().has_point(obj_pos + rect_position):
			var alpha = float(8.0 / (mob_marker.rect_position.distance_to(player_marker.rect_position)))
			if alpha < 0.35:
				alpha = 0.0
			if mob.target != null:
				mob_marker.modulate =  Color(1.0,1.0,0.0,alpha) if (mob.target is Vector2) else Color(1.0,0.0,0.0,alpha)
			mob_marker.modulate.a = alpha
			mob_marker.show()
		else:
			mob_marker.hide()


