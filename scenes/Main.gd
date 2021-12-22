extends Node2D

onready var n_Tilemap := $TileMap
onready var n_Player := $TileMap/Entities/Mobs/Player
onready var n_Crosshair := $Crosshair

func _ready() -> void:
	randomize()
	n_Player.connect("on_footstep",n_Tilemap,"_on_mob_footstep")
	n_Player.connect("on_aiming_start", n_Crosshair, "_on_Player_on_aiming_start")
	n_Player.connect("on_aiming_stop", n_Crosshair, "_on_Player_on_aiming_stop")

	n_Player.can_move = false
	n_Player.set_process_unhandled_key_input(false)

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

	$WorldEnvironment.environment = preload("res://assets/res/env/enviroment.tres")
	$WorldEnvironment.environment.adjustment_saturation = 0.0

	$UI/ScreenMessage/Label.text = "NOW ENTERING:\n" + n_Tilemap.map_name
	$UI/ScreenMessage/Label.percent_visible = 0

	# FX

	if !Global.GameOptions.graphics.render_mist:
		$MistLayer.queue_free()
	else:
		$MistLayer/ColorRect.visible = true

	if !Global.GameOptions.graphics.render_noise:
		$NoiseLayer.queue_free()
	else:
		$NoiseLayer/ColorRect.visible = true

	if !Global.GameOptions.graphics.render_vignette:
		$VignetteLayer.queue_free()
	else:
		$VignetteLayer/ColorRect.visible = true

	var n_ZombieSpawner := $TileMap/ZombieSpawner
	var weapon

	match Global.GameOptions.gameplay.difficulty:
		Globals.Difficulty.EASY:
			weapon = preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn").instance()
			weapon.bullets = 90

			n_ZombieSpawner.mob_max = 100
			n_ZombieSpawner.mob_group_max = 4
			n_ZombieSpawner.spawn_delay_sec = 0.5
			n_ZombieSpawner.restart_delay = 15
		Globals.Difficulty.NORMAL:
			weapon = preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/LeadPipe/LeadPipe.tscn").instance()

			n_ZombieSpawner.mob_max = 200
			n_ZombieSpawner.mob_group_max = 8
			n_ZombieSpawner.spawn_delay_sec = 0.35
			n_ZombieSpawner.restart_delay = 12
		Globals.Difficulty.HARD:
			n_ZombieSpawner.mob_max = 250
			n_ZombieSpawner.mob_group_max = 10
			n_ZombieSpawner.spawn_delay_sec = 0.25
			n_ZombieSpawner.restart_delay = 10

	if weapon != null:
		n_Player.equipment.equip(weapon)

func on_intro_ready() -> void:
	n_Player.can_move = true
	n_Player.set_process_unhandled_key_input(true)
	EventBus.emit_signal("intro_finished")

func _on_Button_button_up():
	get_tree().reload_current_scene()

func _on_Bike_on_full_tank():
	n_Player.can_move = false
	n_Player.set_process_unhandled_key_input(false)

	$AnimationPlayer.play("win")

	var music := preload("res://assets/music/winning.mp3")
	EventBus.emit_signal("play_music", music)

func _on_Player_on_death():
	n_Player.can_move = false
	n_Player.set_process_unhandled_key_input(false)

	var lose := preload("res://assets/music/losing.mp3")
	EventBus.emit_signal("play_music", lose)

	$AnimationPlayer.play("death")
