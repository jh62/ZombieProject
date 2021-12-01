class_name Globals extends Node

enum Difficulty {
	EASY = 0,
	NORMAL,
	HARD
}

const NORMAL_MAP_TEXTURE : Texture = preload("res://assets/spritesheet_n.png")

const GROUP_PLAYER := "player"
const GROUP_ZOMBIE := "zombie"

const MAX_FUEL_LITERS := 5.5 # 120.5

const GameOptions := {
	"gameplay": {
		"difficulty": Difficulty.NORMAL,
		"discard_bullets": 1,
		"auto_pickup": 1
	},
	"graphics": {
		"render_bullets": 1,
		"render_mags": 1,
		"render_blood": 1,
	}
}
