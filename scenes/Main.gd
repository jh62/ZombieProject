extends Node2D

onready var tilemap := $Map/TileMap
onready var camera := $YSort/Player/Camera

func _ready() -> void:
	randomize()
	$Map/TileMap.area_connect_to_mob($YSort/Player)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = $Map/Background.get_rect().size.x
	camera.limit_bottom = $Map/Background.get_rect().size.y

func _process(delta):
	$UI/Button.visible = !$YSort/Player.is_alive()

func _on_Button_button_up():
	get_tree().reload_current_scene()
