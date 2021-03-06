extends NinePatchRect

#const GROUP_MINIMAP_ICON = "minimap_icon"

var minimap_icon

onready var player_marker := $PlayerMarker
onready var mob_marker := $MobMarker
onready var fuel_marker := $FuelMarker

var player : Node2D
var zoom = 0.5
var grid_scale
var markers := {}
var fuel_markers := {}

func _ready():
	EventBus.connect("mob_spawned", self, "_mob_spawned")
	player_marker.rect_position = rect_size / 2
	grid_scale = rect_size / (get_viewport_rect().size * zoom)

func _mob_spawned(mob : Node2D) -> void:
#	add_to_group(GROUP_MINIMAP_ICON)
	var new_marker = mob_marker.duplicate()
	add_child(new_marker)
	new_marker.show()
	markers[mob] = new_marker
	
func _process(delta):
	if !player || markers.empty(): #&& fuel_markers.empty()):
		return
#	player_marker.rotation = player.rotation + PI/2

#	for _f in fuel_markers.keys():
#		var _f_marker = fuel_markers[_f]
#
#		if !is_instance_valid(_f):
#			_f_marker.queue_free()
#			fuel_markers.erase(_f)
#			continue
#
#		var obj_pos = (_f.position - player.position) * grid_scale + rect_size / 2
#		obj_pos.x = clamp(obj_pos.x, 0, rect_size.x)
#		obj_pos.y = clamp(obj_pos.y, 0, rect_size.y)
#		_f_marker.rect_poswition = obj_pos
#
#		if get_rect().has_point(obj_pos + rect_position):
#			if _f_marker.rect_position.distance_to(player_marker.rect_position) < 16.0:
#				_f_marker.show()
#			else:
#				_f_marker.hide()
#		else:
#			_f_marker.hide()

	for mob in markers.keys():
		var mob_marker = markers[mob]

		if !mob.is_alive():
			mob_marker.queue_free()
			markers.erase(mob)
			continue

		var obj_pos = (mob.position - player.position) * grid_scale + rect_size / 2
		obj_pos.x = clamp(obj_pos.x, 0, rect_size.x)
		obj_pos.y = clamp(obj_pos.y, 0, rect_size.y)
		mob_marker.rect_position = obj_pos

		if get_rect().has_point(obj_pos + rect_position):
			var alpha = float(8.0 / (mob_marker.rect_position.distance_to(player_marker.rect_position)))
			if alpha < 0.15:
				alpha = 0.0
			if mob.target != null:
				mob_marker.modulate =  Color(1.0,1.0,0.0,alpha) if (mob.target is Vector2) else Color(1.0,0.0,0.0,alpha)

			mob_marker.modulate.a = alpha
			mob_marker.show()
		else:
			mob_marker.hide()


