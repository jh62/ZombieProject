class_name Globals extends Node

enum Difficulty {
	EASY = 0,
	NORMAL,
	HARD
}

enum WeaponNames {
	DISARMED = -1,
	PISTOL,
	SHOTGUN,
	SMG,
	RIFLE,
	LEADPIPE,
	MACHETE,
	SWORD
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
		"auto_pickup": 0,
		"death_wish": 0,
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
