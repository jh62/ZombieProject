class_name Globals extends Node

const POINTER_16 := preload("res://assets/ui/cursors/pointer16.png")
const POINTER_32 := preload("res://assets/ui/cursors/pointer32.png")
const POINTER_64 := preload("res://assets/ui/cursors/pointer64.png")

enum Difficulty {
	EASY = 0,
	NORMAL,
	HARD
}

enum WeaponNames {
	PISTOL = 0,
	SHOTGUN,
	SMG,
	RIFLE,
	LEADPIPE,
	MACHETE,
	SWORD,
	DISARMED
}

const NORMAL_MAP_TEXTURE : Texture = preload("res://assets/spritesheet_n.png")

const GROUP_PLAYER := "player"
const GROUP_ZOMBIE := "zombie"
const GROUP_FIRE := "fire"

const MAX_FUEL_LITERS := 12.5 # 120.5

var GameOptions := {
	"gameplay": {
		"difficulty": Difficulty.NORMAL,
		"discard_bullets": 1,
		"auto_pickup": 1,
		"death_wish": 0,
		"joypad": 0,
	},
	"graphics": {
		"render_bullets": 1,
		"render_mags": 1,
		"render_blood": 1,
		"render_mist": 1,
		"render_noise": 1,
		"render_vignette": 1,
		"corpses_decay": 0
	},
	"audio": {
		"music_db": 0.0,
		"sound_db": 0.0,
		"player_footsteps": 0.0,
		"zombie_footsteps": 0.0
	}
}
