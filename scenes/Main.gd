extends Node2D

onready var n_Tilemap := $TileMap
onready var n_Player := $TileMap/Entities/Mobs/Player
onready var n_Crosshair := $TileMapTileMap/Entities/Mobs/Player/Crosshair
onready var n_ScreenMessage := $UI/ScreenMessage
onready var n_Dialog := $UI/DialogPopup

func _ready() -> void:
	randomize()

	EventBus.connect("fuel_pickedup", self, "_on_fuel_pickedup")

	n_Player.connect("on_footstep",n_Tilemap,"_on_mob_footstep")
	n_Player.can_move = false
	n_Player.set_process_unhandled_key_input(false)

	var n_Camera := n_Player.get_node("Camera")
	n_Camera.limit_top = 0
	n_Camera.limit_left = 0
	n_Camera.limit_right = n_Tilemap.get_node("TileMap/Background").get_rect().size.x
	n_Camera.limit_bottom = n_Tilemap.get_node("TileMap/Background").get_rect().size.y

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

	$TileMap/Entities.connect("on_mob_spawned", n_Tilemap, "_on_mob_spawned")

	var n_ZombieSpawner := $TileMap/ZombieSpawner
	var weapon

	match Global.GameOptions.gameplay.difficulty:
		Globals.Difficulty.EASY:
			weapon = preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn").instance()
			weapon.bullets = 250

			n_ZombieSpawner.mob_max = 150
			n_ZombieSpawner.mob_group_max = 4
			n_ZombieSpawner.spawn_delay_sec = 0.5
			n_ZombieSpawner.restart_delay = 12
		Globals.Difficulty.NORMAL:
			weapon = preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn").instance()
			weapon.bullets = 200

			n_ZombieSpawner.mob_max = 200
			n_ZombieSpawner.mob_group_max = 8
			n_ZombieSpawner.spawn_delay_sec = 0.35
			n_ZombieSpawner.restart_delay = 10
		Globals.Difficulty.HARD:
			weapon = preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn").instance()
			weapon.bullets = 180

			n_ZombieSpawner.mob_max = 250
			n_ZombieSpawner.mob_group_max = 10
			n_ZombieSpawner.spawn_delay_sec = 0.25
			n_ZombieSpawner.restart_delay = 8

	if weapon != null:
		yield(get_tree().create_timer(.25),"timeout")
		n_Player.equip_item(weapon)

func _unhandled_key_input(event):
	if Input.is_key_pressed(KEY_F11):
		OS.window_fullscreen = !(OS.window_fullscreen)
		if !OS.window_fullscreen:
			OS.window_size = Vector2(640,480)
	if Input.is_action_just_released("quit_confirm"):
		if n_ScreenMessage.visible || n_Dialog.visible:
			$AnimationPlayer.playback_speed = 10.0
			yield($AnimationPlayer,"animation_finished")
			$AnimationPlayer.playback_speed = 1.0

func on_intro_ready() -> void:
	n_Player.can_move = true
	n_Player.set_process_unhandled_key_input(true)
	EventBus.emit_signal("intro_finished")

func _on_Button_button_up():
	if Global.GameOptions.gameplay.death_wish:
		var new_scene := preload("res://scenes/UI/Menus/TitleScreen/TitleScreen.tscn")
		get_tree().change_scene_to(new_scene)
	else:
		get_tree().reload_current_scene()

func _on_Bike_on_full_tank():
	for mob in $TileMap/Entities/Mobs.get_children():
		if !(mob is Mobile):
			continue
		mob.can_move = false

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

var fuel_pickedup_first := false

func _on_fuel_pickedup(amount) -> void:
	if fuel_pickedup_first:
		return

	fuel_pickedup_first = true
	$AnimationPlayer.play("fuel_hint")

const messages := [
		"That was not enough. I need more.",
		"I need a few more.",
		"I need some more.",
		"Damn, I need to find another one."
	]

func _on_Bike_on_fuel_stopped(amount):
	if amount >= Globals.MAX_FUEL_LITERS:
		return

	messages.shuffle()
	$UI/DialogPopup/MarginContainer/LabelDialog.text = messages.front()
	$AnimationPlayer.call_deferred("play","fuel_changed")

func _on_PauseMessage_on_pause():
	n_Dialog.visible = !n_Dialog.visible

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"intro":
			yield(get_tree().create_timer(1.0),"timeout")
			$AnimationPlayer.play("intro_dialog")
