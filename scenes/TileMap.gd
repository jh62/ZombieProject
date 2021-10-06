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
