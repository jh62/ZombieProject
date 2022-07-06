class_name Globals extends Node

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
	SWORD,
	DISARMED
}

enum ZombieType {
	COMMON = 0,
	POLICE,
	FIREFIGHTER,
	ABOMINATION,
	CRAWLER
}

const PERK_GLOBAL_PRICE := 500

const PerkPrices := {
	Perk.PERK_TYPE.FREE_FIRE: PERK_GLOBAL_PRICE * 12,
	Perk.PERK_TYPE.HOLLYWOOD_MAG: PERK_GLOBAL_PRICE * 10.2,
	Perk.PERK_TYPE.ADRENALINE: PERK_GLOBAL_PRICE * 10.66,
	Perk.PERK_TYPE.FAST_RELOAD: PERK_GLOBAL_PRICE * 5.3,
	Perk.PERK_TYPE.FIXXXER: PERK_GLOBAL_PRICE * 1.84,
	Perk.PERK_TYPE.MOONWALKER: PERK_GLOBAL_PRICE * 1.6,
	Perk.PERK_TYPE.SHADOW_DANCER: PERK_GLOBAL_PRICE * 3.7,
	Perk.PERK_TYPE.TOUGH_GUY: PERK_GLOBAL_PRICE * 2.4,
}

const CINEMATIC_MODE := false

const POINTER_16 := preload("res://assets/ui/cursors/pointer16.png")
const POINTER_32 := preload("res://assets/ui/cursors/pointer32.png")
const POINTER_64 := preload("res://assets/ui/cursors/pointer64.png")

const NORMAL_MAP_TEXTURE : Texture = preload("res://assets/spritesheet_n.png")

const GROUP_PLAYER := "player"
const GROUP_HOSTILES := "hostiles"
const GROUP_ZOMBIE := "zombie"
const GROUP_SPECIAL := "special"
const GROUP_FIRE := "fire"
const GROUP_MOBILE := "mobile"
const GROUP_FUELCAN := "fuelcan"
const GROUP_KEYS := "keys"

const MAX_FUEL_LITERS := 12.5 # 120.5
const MAX_SPECIAL_ZOMBIES := 4

const MAX_CASH := 100000

var DEBUG_MODE := false

var MAP_SIZE := Vector2()

var CLOCK := 1.0

var GameOptions := {
	"gameplay": {
		"difficulty": Difficulty.HARD,
		"discard_bullets": 0,
		"auto_pickup": 0,
		"death_wish": 0,
		"joypad": 0,
	},
	"graphics": {
		"render_bullets": 1,
		"render_mags": 0,
		"render_blood": 1,
		"render_mist": 1,
		"render_noise": 1,
		"render_vignette": 1,
		"corpses_decay": 1
	},
	"audio": {
		"music_db": 0.0,
		"sound_db": 0.0,
		"player_footsteps": 0.0,
		"zombie_footsteps": 0.0
	}
}

func set_canvas_item_light_mask_value(canvas_item: CanvasItem, layer_number: int, value: bool) -> void:
	assert(layer_number >= 1 and layer_number <= 20, "layer_number must be between 1 and 20 inclusive")
	if value:
		canvas_item.light_mask |= 1 << (layer_number - 1)
	else:
		canvas_item.light_mask &= ~(1 << (layer_number - 1))

static func get_area_point(_position, _radius := 50.0) -> Vector2:
	var angle := rand_range(0.0, 2.0) * PI
	var dir := Vector2(sin(angle),cos(angle))
	var radius := _radius
	var target_pos = _position + dir * radius

	return target_pos
