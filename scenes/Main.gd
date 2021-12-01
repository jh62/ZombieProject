extends Node2D

onready var n_Tilemap := $TileMap
onready var n_Player := $TileMap/Entities/Mobs/Player

func _ready() -> void:
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	n_Player.connect("on_footstep",n_Tilemap,"_on_mob_footstep")

	var n_Camera := n_Player.get_node("Camera")
	n_Camera.limit_top = 0
	n_Camera.limit_left = 0
	n_Camera.limit_right = n_Tilemap.get_node("Background").get_rect().size.x
	n_Camera.limit_bottom = n_Tilemap.get_node("Background").get_rect().size.y

	if OS.get_name().is_subsequence_ofi("Android"):
		$WorldEnvironment.queue_free()
		$CanvasModulate.queue_free()
	else:
		$WorldEnvironment.environment = preload("res://assets/res/env/enviroment.tres")
		$CanvasModulate.visible = true

	$UI/ScreenMessage.visible = false

	$WorldEnvironment.environment = preload("res://assets/res/env/enviroment.tres")
	$WorldEnvironment.environment.adjustment_saturation = 0.0
	$UI/ScreenMessage.visible = true
	$UI/ScreenMessage/Label.text = "NOW ENTERING:\n" + n_Tilemap.map_name
	$UI/ScreenMessage/Label.percent_visible = 0

	var weapon := preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/LeadPipe/LeadPipe.tscn").instance()
	n_Player.equipment.equip(weapon)

func _process(delta):
	$UI/Button.visible = !n_Player.is_alive()

func on_intro_ready() -> void:
	EventBus.emit_signal("intro_finished")

func _on_Button_button_up():
	get_tree().reload_current_scene()

func _on_Bike_on_full_tank():
	var enviroment : Environment = $WorldEnvironment.environment
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
	var enviroment : Environment = $WorldEnvironment.environment
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
