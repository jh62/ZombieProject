extends Node2D

onready var n_Tilemap := $TileMap
onready var n_Player := $TileMap/Entities/Mobs/Player

func _ready() -> void:
	randomize()
	n_Player.connect("on_footstep",n_Tilemap,"_on_mob_footstep")

	var n_Camera := n_Player.get_node("Camera")
	n_Camera.limit_left = 0
	n_Camera.limit_top = 0
	n_Camera.limit_right = n_Tilemap.get_node("Background").get_rect().size.x
	n_Camera.limit_bottom = n_Tilemap.get_node("Background").get_rect().size.y

func _process(delta):
	$UI/Button.visible = !n_Player.is_alive()

func _on_Button_button_up():
	get_tree().reload_current_scene()
