extends Node2D

onready var tilemap := $Map/TileMap

func _ready() -> void:
	$Map/TileMap.area_connect_to_mob($YSort/Player)
