extends Node2D

onready var n_Tilemap := $TileMap
onready var n_Player := $TileMap/Entities/Mobs/Player

func _ready() -> void:
	randomize()
	n_Player.connect("on_footstep",n_Tilemap,"_on_mob_footstep")

	var n_Camera := n_Player.get_node("Camera")
	n_Camera.limit_top = 0
	n_Camera.limit_left = 0
	n_Camera.limit_right = n_Tilemap.get_node("Background").get_rect().size.x
	n_Camera.limit_bottom = n_Tilemap.get_node("Background").get_rect().size.y

	if OS.get_name().is_subsequence_ofi("Android"):
		$TileMap/WorldEnvironment.queue_free()
		$TileMap/CanvasModulate.queue_free()
	else:
		$TileMap/WorldEnvironment.environment = preload("res://assets/res/env/enviroment.tres")
		$TileMap/CanvasModulate.visible = true

	$UI/ScreenMessage.visible = false

	$TileMap/WorldEnvironment.environment = preload("res://assets/res/env/enviroment.tres")
	$TileMap/WorldEnvironment.environment.adjustment_saturation = 0.0
	$UI/ScreenMessage.visible = true
	$UI/ScreenMessage/Label.text = "NOW ENTERING:\n" + n_Tilemap.map_name
	$UI/ScreenMessage/Label.percent_visible = 0
#	$Tween.interpolate_property($TileMap/WorldEnvironment.environment, "adjustment_saturation", 0.0, 1.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.1)
#	$Tween.interpolate_property($UI/ScreenMessage/Label, "percent_visible", 0, 1, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.5)
#	$Tween.interpolate_property($UI/ScreenMessage, "visible", true, false, 0.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 5.0)
#	$Tween.interpolate_property($TileMap/Entities/Mobs/Player/Camera, "zoom", Vector2(.25,.25),Vector2(1,1),5.0,Tween.TRANS_LINEAR,Tween.EASE_OUT,1.0)
#	$Tween.start()
#	yield($Tween,"tween_all_completed")
#	EventBus.emit_signal("map_ready")

func _process(delta):
	$UI/Button.visible = !n_Player.is_alive()

func _on_Button_button_up():
	get_tree().reload_current_scene()

func _on_Bike_on_full_tank():
	var enviroment : Environment = $TileMap/WorldEnvironment.environment
	var screen_message := $UI/ScreenMessage
	var screen_message_label := $UI/ScreenMessage/Label
	var tween := $Tween

	n_Player.can_move = false
	n_Player.set_process_unhandled_input(false)
	screen_message.visible = true
	screen_message_label.percent_visible = 0
	screen_message_label.text = "YOU SURVIVED"

	tween.interpolate_property(enviroment, "adjustment_saturation", 1.0, 0.0, 3.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.0)
	tween.interpolate_property(screen_message_label, "percent_visible", 0, 1, 1.25, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.0)
	tween.start()

func _on_Player_on_death():
	var enviroment : Environment = $TileMap/WorldEnvironment.environment
	var screen_message := $UI/ScreenMessage
	var screen_message_label := $UI/ScreenMessage/Label
	var music_player := $TileMap/Entities/Mobs/Player/Camera/SoundManager.get_node("MusicPlayer")
	var tween := $Tween

	var start_color := Color(1.0,0.0,0.0,0.0)
	var end_color := Color(1.0,0.0,0.0,0.8)

	n_Player.can_move = false
	n_Player.set_process_unhandled_input(false)
	screen_message.visible = true
	screen_message_label.percent_visible = 0
	screen_message_label.text = "YOU ARE DEAD"

	music_player.stream = load("res://assets/music/losing.mp3")
	music_player.play()

	tween.interpolate_property(enviroment, "adjustment_saturation", 1.0, 0.0, 3.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.0)
	tween.interpolate_property(screen_message_label, "percent_visible", 0, 1, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.0)
	tween.start()
