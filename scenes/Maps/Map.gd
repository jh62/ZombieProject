class_name Map extends Node

enum TileMaterial {
	GRASS,
	CEMENT,
	DIRT,
	METAL
}

const MaterialSound := {
	TileMaterial.GRASS: {
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
	TileMaterial.CEMENT:{
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
	TileMaterial.DIRT:{
		"sound": {
			Globals.GROUP_PLAYER: [],
			Globals.GROUP_ZOMBIE: []
		}
	},
	TileMaterial.METAL:{
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

onready var n_SpawnAreas := $SpawnAreas
onready var n_TilemapTop : TileMap = $TileMapTop setget ,get_tilemap
onready var n_TilemapBottom : TileMap = n_TilemapTop.get_node("TileMapBottom")
onready var n_TilemapRoofs : TileMap = $TileMapRoofs
onready var n_Navigation := $Navigation
onready var n_TileMap : TileMap = n_Navigation.get_node("TileMap")
onready var n_Entities := $TileMapTop/Entities

var pathfind := AStar2D.new()

func _ready():
	Global.MAP_SIZE = n_TilemapBottom.get_used_rect().size * 16

	if !n_TilemapRoofs.visible:
		n_TilemapRoofs.visible = true

	_create_pathfinding()

	n_Entities.connect("on_mob_spawned", self, "_on_mob_spawned")

func _create_pathfinding() -> void:
	var usable_tiles : PoolVector2Array

	var walkable_tiles = n_TilemapBottom.get_used_cells()
	var no_walkable_tiles = n_TilemapTop.get_used_cells()
	var max_tiles : int = walkable_tiles.size()
	for i in max_tiles:
		var t = walkable_tiles[i]
		if t in no_walkable_tiles:
			continue
		n_TileMap.set_cellv(t, 43)

	for object in n_Entities.get_node("Statics").get_children():
		if !object.has_node("CollisionShape") || (object is Door):
			continue
		var cellv = n_TileMap.world_to_map(object.global_position)
		n_TileMap.set_cellv(cellv, -1)

	for tile in n_TileMap.get_used_cells():
		var tileid = get_tile_id(tile)
		pathfind.add_point(tileid, tile)

	var DIRECTIONS := [
		Vector2.LEFT,
		Vector2.UP,
		Vector2.RIGHT,
		Vector2.DOWN,
		Vector2.UP + Vector2.LEFT,
		Vector2.UP + Vector2.RIGHT,
		Vector2.DOWN + Vector2.LEFT,
		Vector2.DOWN + Vector2.RIGHT]

#	var DIRECTIONS := [Vector2.LEFT,Vector2.UP,Vector2.RIGHT,Vector2.DOWN]

	for tile in n_TileMap.get_used_cells():
		var tileid = get_tile_id(tile)
		for d in DIRECTIONS:
			var neighbour : Vector2 = tile + d
			var n_id = get_tile_id(neighbour)

			if tileid == n_id:
				continue

			if !pathfind.has_point(n_id):
				continue

			if !pathfind.are_points_connected(tileid, n_id):
				pathfind.connect_points(tileid, n_id)

func get_waypoint_nav(from : Vector2, to : Vector2) -> PoolVector2Array:
	var points = n_Navigation.get_simple_path(from, to, false)

	if points.size() > 0:
		points.remove(0)

	return points as PoolVector2Array

func get_waypoints_to(from : Vector2, to : Vector2) -> PoolVector2Array:
	var cell_from := n_TilemapBottom.world_to_map(from)
	var cell_to := n_TilemapBottom.world_to_map(to)

	return pathfind.get_point_path(get_tile_id(cell_from), get_tile_id(cell_to))

func get_world_pos(cellv : Vector2) -> Vector2:
	return get_tilemap().map_to_world(cellv)

func get_tilemap() -> TileMap:
	return n_TileMap

func update_tile_status(pos : Vector2, disabled) -> void:
	var mob_cell := get_tilemap().world_to_map(pos)
	pathfind.set_point_disabled(get_tile_id(mob_cell), disabled)

static func get_tile_id(point : Vector2) -> int:
	var a = point.x
	var b = point.y
	return (a+b) * (a+b+1) / 2+b

func generate_loot() -> void:
	for x in range(0, $TileMap/Background.region_rect.size.x, 16):
		for y in range(0, $TileMap/Background.region_rect.size.y, 16):
			var pos := Vector2(x, y)
			var chance := randf()
			if .027 >= chance:
				EventBus.emit_signal("on_object_spawn", preload("res://scenes/Entities/Items/Pickable/LootItem/LootItem.tscn"), pos)
			elif .016 >= chance:
				var weapon := preload("res://scenes/Entities/Items/Pickable/PickableWeapon/PickableWeapon.tscn").instance()
				weapon.random_drop = true
				EventBus.emit_signal("on_object_spawn", weapon, pos)

func _on_mob_spawned(mob : Mobile) -> void:
	mob.map = self
	mob.connect("on_footstep", self, "_on_mob_footstep")

var step_sounds := 0
var yielding := false

func _on_mob_footstep(mob : Mobile) -> void:
	var grp

	if mob.is_in_group(Global.GROUP_PLAYER):
		grp = Global.GROUP_PLAYER
		var map_pos := n_TilemapRoofs.world_to_map(mob.global_position)
		if n_TilemapRoofs.get_cellv(map_pos) != TileMap.INVALID_CELL:
			if n_TilemapRoofs.modulate.a == 1.0:
				$Tween.stop_all()
				$Tween.interpolate_property(n_TilemapRoofs,"modulate", n_TilemapRoofs.modulate,Color(1,1,1,.15), 0.33,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, .15)
				$Tween.start()
		else:
			if n_TilemapRoofs.modulate.a != 1.0:
				$Tween.stop_all()
				$Tween.interpolate_property(n_TilemapRoofs,"modulate", n_TilemapRoofs.modulate, Color(1,1,1,1.0), 0.33,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, .15)
				$Tween.start()

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

	var snd = MaterialSound[TileMaterial.CEMENT].sound.get(grp)
	var volume_db

	match grp:
		Globals.GROUP_ZOMBIE:
			volume_db = Global.GameOptions.audio.zombie_footsteps
		_:
			volume_db = Global.GameOptions.audio.player_footsteps

	EventBus.emit_signal("play_sound_random", snd, mob.global_position, rand_range(.95,1.05), volume_db)
