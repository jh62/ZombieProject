extends TileMap

enum ColorCodes {
	GRASS,
	CEMENT,
	DIRT,
	METAL
}

const sound_color_codes := {
	ColorCodes.GRASS: {
		"hex": "",
		"sound": {
			Global.GROUP_PLAYER: [
				preload("res://assets/sfx/footsteps/player/footstep_grass_1.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_grass_2.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_grass_3.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_grass_4.wav")
			],
			Global.GROUP_ZOMBIE: [
				preload("res://assets/sfx/footsteps/zombie/footstep_grass_z_1.wav"),
				preload("res://assets/sfx/footsteps/zombie/footstep_grass_z_2.wav"),
				preload("res://assets/sfx/footsteps/zombie/footstep_grass_z_3.wav"),
				preload("res://assets/sfx/footsteps/zombie/footstep_grass_z_4.wav"),
			]
		}
	},
	ColorCodes.CEMENT:{
		"hex": "",
		"sound": {
			Global.GROUP_PLAYER: [
				preload("res://assets/sfx/footsteps/player/footstep_cement_1.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_cement_2.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_cement_3.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_cement_4.wav"),
			],
			Global.GROUP_ZOMBIE: [
				preload("res://assets/sfx/footsteps/zombie/footstep_cement_z_1.wav"),
				preload("res://assets/sfx/footsteps/zombie/footstep_cement_z_2.wav"),
				preload("res://assets/sfx/footsteps/zombie/footstep_cement_z_3.wav"),
				preload("res://assets/sfx/footsteps/zombie/footstep_cement_z_4.wav"),
			]
		}
	},
	ColorCodes.DIRT:{
		"hex": "",
		"sound": {
			Global.GROUP_PLAYER: [],
			Global.GROUP_ZOMBIE: []
		}
	},
	ColorCodes.METAL:{
		"hex": "",
		"sound": {
			Global.GROUP_PLAYER: [
				preload("res://assets/sfx/footsteps/player/footstep_metal_1.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_metal_2.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_metal_3.wav"),
			],
			Global.GROUP_ZOMBIE: [
				preload("res://assets/sfx/footsteps/zombie/footstep_metal_z_1.wav"),
				preload("res://assets/sfx/footsteps/zombie/footstep_metal_z_2.wav"),
				preload("res://assets/sfx/footsteps/zombie/footstep_metal_z_3.wav"),
			]
		}
	},
}

onready var n_navigation := $Navigation2D

var json : JSONParseResult
var texture : Image

func _ready():
	var file := File.new()
	file.open("res://assets/maps/map_test.json",File.READ)
	json = JSON.parse(file.get_as_text())

	sound_color_codes[ColorCodes.GRASS].hex = json.result["grass"]
	sound_color_codes[ColorCodes.CEMENT].hex = json.result["cement"]
	sound_color_codes[ColorCodes.DIRT].hex = json.result["dirt"]
	sound_color_codes[ColorCodes.METAL].hex = json.result["metal"]

	texture = $Background.texture.get_data()
	texture.lock()

	_update_navigation_polygon()

func _update_navigation_polygon() -> void:
	var statics = get_node("MapObjects")

	for obj in statics.get_children():
		if !(obj is StaticObject):
			continue
		var poly = obj.get_node("CollisionShape").get_polygon()
		var outlines : PoolVector2Array
		for p in poly:
			outlines.append(obj.position + p)
		$Navigation2D/NavigationPolygonInstance.get_navigation_polygon().add_outline(outlines)

#	for cell_pos in get_used_cells_by_id(13):
#		var cell_id = get_cellv(cell_pos)
##		if cell_id != 13 && cell_id != 14:
##			continue
#		var outlines : PoolVector2Array
#		var pos = map_to_world(cell_pos)
#		outlines.append(pos + Vector2(0,0))
#		outlines.append(pos + Vector2(cell_size.x,0))
#		outlines.append(pos + Vector2(cell_size.x,cell_size.y))
#		outlines.append(pos + Vector2(0,cell_size.y))
#		print_debug(pos)
#		$Navigation2D/NavigationPolygonInstance.get_navigation_polygon().add_outline(outlines)

	$Navigation2D/NavigationPolygonInstance.get_navigation_polygon().make_polygons_from_outlines()
	$Navigation2D/NavigationPolygonInstance.enabled = false
	yield(get_tree(),"idle_frame")
	$Navigation2D/NavigationPolygonInstance.enabled = true

func _on_mob_spawned(mob : Mobile) -> void:
	mob.connect("on_footstep", self, "_on_mob_footstep")

func _on_mob_footstep(mob : Mobile) -> void:
	var pix := texture.get_pixel(mob.global_position.x, mob.global_position.y + 720).to_html().substr(2)
	var code

	if pix in sound_color_codes.get(ColorCodes.GRASS).hex:
		code = ColorCodes.GRASS
	elif pix in sound_color_codes.get(ColorCodes.CEMENT).hex:
		code = ColorCodes.CEMENT
	elif pix in sound_color_codes.get(ColorCodes.METAL).hex:
		code = ColorCodes.METAL
	else:
		return

	var grp

	if mob.is_in_group(Global.GROUP_PLAYER):
		grp = Global.GROUP_PLAYER
	else:
		grp = Global.GROUP_ZOMBIE

	var snd = sound_color_codes[code].sound.get(grp)
	EventBus.emit_signal("play_sound_random", snd, mob.global_position)
