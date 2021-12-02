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
			Globals.GROUP_PLAYER: [
				preload("res://assets/sfx/footsteps/player/footstep_grass_1.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_grass_2.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_grass_3.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_grass_4.wav")
			],
			Globals.GROUP_ZOMBIE: [
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
			Globals.GROUP_PLAYER: [
				preload("res://assets/sfx/footsteps/player/footstep_cement_1.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_cement_2.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_cement_3.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_cement_4.wav"),
			],
			Globals.GROUP_ZOMBIE: [
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
			Globals.GROUP_PLAYER: [],
			Globals.GROUP_ZOMBIE: []
		}
	},
	ColorCodes.METAL:{
		"hex": "",
		"sound": {
			Globals.GROUP_PLAYER: [
				preload("res://assets/sfx/footsteps/player/footstep_metal_1.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_metal_2.wav"),
				preload("res://assets/sfx/footsteps/player/footstep_metal_3.wav"),
			],
			Globals.GROUP_ZOMBIE: [
				preload("res://assets/sfx/footsteps/zombie/footstep_metal_z_1.wav"),
				preload("res://assets/sfx/footsteps/zombie/footstep_metal_z_2.wav"),
				preload("res://assets/sfx/footsteps/zombie/footstep_metal_z_3.wav"),
			]
		}
	},
}

export var map_name := ""

onready var n_navigation := $Navigation2D

var json : JSONParseResult
var texture : Image

func _ready():
	$Entities.connect("on_mob_spawned", self, "_on_mob_spawned")

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

	# generate random loot
	for x in range(0, $Background.region_rect.size.x, 16):
		for y in range(0, $Background.region_rect.size.y, 16):
			var pos := Vector2(x, y)
			var chance := randf()
			if .027 >= chance:
				EventBus.emit_signal("on_object_spawn", preload("res://scenes/Entities/Items/Pickable/LootItem/LootItem.tscn"), pos)
			elif .016 >= chance:
				var weapon := preload("res://scenes/Entities/Items/Pickable/PickableWeapon/PickableWeapon.tscn").instance()
				weapon.random_drop = true
				EventBus.emit_signal("on_object_spawn", weapon, pos)

	for c in $MapObjects.get_children():
		c.visible = true

func make_outlines(objects) -> void:
	for obj in objects:
		if !(obj is StaticObject):
			continue
#		if !obj.visible:
#			return
		var outlines : PoolVector2Array
		var offset = obj.get_node("Sprite").offset
		var shape = obj.get_node("CollisionShape")
		for p in shape.get_polygon():
			outlines.append(obj.global_position + shape.position + p)

		$Navigation2D/NavigationPolygonInstance.get_navigation_polygon().add_outline(outlines)
		$Navigation2D/NavigationPolygonInstance.get_navigation_polygon().make_polygons_from_outlines()

func _update_navigation_polygon() -> void:
	var buildings := $MapObjects/Buildings.get_children()
	var objects := $MapObjects/Objects.get_children()
	var streetlamps := $MapObjects/StreetLamps.get_children()

	make_outlines(buildings)
	make_outlines(objects)
	make_outlines(streetlamps)

	$Navigation2D/NavigationPolygonInstance.enabled = false
	yield(get_tree(),"idle_frame")
	$Navigation2D/NavigationPolygonInstance.enabled = true

func _on_mob_spawned(mob : Mobile) -> void:
	mob.connect("on_footstep", self, "_on_mob_footstep")

var step_sounds := 0
var yielding := false

func _on_mob_footstep(mob : Mobile) -> void:
	var grp

	if mob.is_in_group(Global.GROUP_PLAYER):
		grp = Global.GROUP_PLAYER
	else:
		grp = Global.GROUP_ZOMBIE

	if grp == Globals.GROUP_ZOMBIE:
		step_sounds += 1

		if step_sounds > 1:
			if yielding:
				return
			yielding = true
			yield(get_tree().create_timer(.3),"timeout")
			yielding = false
			step_sounds = 0
			return

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

	var snd = sound_color_codes[code].sound.get(grp)
	EventBus.emit_signal("play_sound_random", snd, mob.global_position)
