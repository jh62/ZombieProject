extends Node2D

export var debug_mode := false setget set_debug_mode

onready var n_MapManager := $MapManager
onready var n_ScreenMessage := $UI/ScreenMessage
onready var n_Dialog := $UI/DialogPopup
onready var n_Hud := $UI/HUD

var n_Player
var n_Crosshair
var n_Entities

func _ready() -> void:
	randomize()
	
	var map
	
	match PlayerStatus.current_level:
		4:
			map = preload("res://scenes/Maps/Harbor/Harbor0.tscn").instance()
		_:
			map = preload("res://scenes/Maps/Outskirts/Outskirts_0.tscn").instance()
			
	n_MapManager.add_child(map)
	
	yield(get_tree().create_timer(0.1),"timeout")

	var current_map = n_MapManager.get_map()
	var _player = current_map.find_node("Player", true, false)
	var _bike = current_map.find_node("Bike", true, false)

	n_Player = _player
	n_Crosshair = n_Player.crosshair

	n_Hud.initialize(_player, _bike)
	$SoundManager.player = _player

	EventBus.connect("on_bike_tank_full", self, "_on_Bike_on_full_tank")
	EventBus.connect("on_escape", self, "_on_escape")
	EventBus.connect("on_loot_pickedup", self, "_on_loot_pickedup")
	EventBus.connect("on_request_update_health", self, "_on_request_update_health")
	EventBus.connect("on_player_death", self, "_on_Player_on_death")

	n_Player.connect("on_footstep",n_MapManager.get_map(),"_on_mob_footstep")
	n_Player.can_move = false
	n_Player.set_process_unhandled_key_input(false)

	var n_Camera : Camera2D = n_Player.get_node("Camera2D")
	n_Camera.limit_top = 0
	n_Camera.limit_bottom = Global.MAP_SIZE.y
	n_Camera.limit_left = 0
	n_Camera.limit_right = Global.MAP_SIZE.x

	if Global.DEBUG_MODE:
		$WorldEnvironment.queue_free()
		$CanvasModulate.queue_free()
	else:
		$WorldEnvironment.environment = preload("res://assets/res/env/enviroment.tres")
		$CanvasModulate.visible = true

	if !Global.DEBUG_MODE:
		$WorldEnvironment.environment = preload("res://assets/res/env/enviroment.tres")
		$WorldEnvironment.environment.adjustment_saturation = 0.0

		$UI/ScreenMessage/Label.text = "NOW ENTERING:\n" + n_MapManager.get_map().map_name
		$UI/ScreenMessage/Label.percent_visible = 0

	# FX

	if !Global.DEBUG_MODE:
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

	var n_ZombieSpawner := $ZombieSpawner	
	
	match Global.GameOptions.gameplay.difficulty:
		Globals.Difficulty.EASY:
			if !Global.DEBUG_MODE:
				n_ZombieSpawner.mob_max = 30
				n_ZombieSpawner.mob_group_max = 4
				n_ZombieSpawner.restart_delay = 30
		Globals.Difficulty.NORMAL:
			if !Global.DEBUG_MODE:
				n_ZombieSpawner.mob_max = 45
				n_ZombieSpawner.mob_group_max = 8
				n_ZombieSpawner.restart_delay = 25
		Globals.Difficulty.HARD:
			if !Global.DEBUG_MODE:
				n_ZombieSpawner.mob_max = 60
				n_ZombieSpawner.mob_group_max = 10
				n_ZombieSpawner.restart_delay = 20
				
	var _p_equipment = _player.get_equipment()				
	_p_equipment.set_primary_item(PlayerStatus.get_weapon(0))
	_p_equipment.set_secondary_item(PlayerStatus.get_weapon(1))
	_p_equipment.equip_primary()

	if Global.CINEMATIC_MODE:
		$UI.layer = -1000
		
func set_debug_mode(_mode) -> void:
	debug_mode = _mode
	Global.DEBUG_MODE = _mode	

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
	for mob in get_tree().get_nodes_in_group(Global.GROUP_MOBILE):
		mob.can_move = false
		
	n_Player.dir = Vector2.ZERO
	n_Player.can_move = false
	n_Player.set_process_unhandled_key_input(false)

	$AnimationPlayer.play("win_full_tank")
	
	PlayerStatus.current_level += 1

	var music := preload("res://assets/music/winning.mp3")
	EventBus.emit_signal("play_music", music)

func _on_escape() -> void:
	for mob in get_tree().get_nodes_in_group(Global.GROUP_MOBILE):
		mob.can_move = false
		
	n_Player.dir = Vector2.ZERO
	n_Player.can_move = false
	n_Player.set_process_unhandled_key_input(false)

	$AnimationPlayer.play("win_final")

	var music := preload("res://assets/music/winning.mp3")
	EventBus.emit_signal("play_music", music)

func _on_Player_on_death(player_mob):
	player_mob.can_move = false
	player_mob.set_process_unhandled_key_input(false)
	
	var lose := preload("res://assets/music/losing.mp3")
	EventBus.emit_signal("play_music", lose)

	$AnimationPlayer.play("death")

var fuel_pickedup_first := false
var label_idx := 0

var LabelPool := [
	preload("res://LabelLoot.tscn").instance(),
	preload("res://LabelLoot.tscn").instance(),
	preload("res://LabelLoot.tscn").instance()
]

func _on_loot_pickedup() -> void:
	var label_root = LabelPool[label_idx]
	var label = label_root.get_node("Label")
	n_MapManager.get_map().add_child(label_root)
	label.rect_global_position = n_Player.global_position
	label.bbcode_text = "[center][color=white]+LOOT"
	label_idx = wrapi(label_idx + 1, 0, LabelPool.size())

func _on_request_update_health() -> void:
	var label_root = LabelPool[label_idx]
	var label = label_root.get_node("Label")
	n_MapManager.get_map().add_child(label_root)
	label.rect_global_position = n_Player.global_position
	label.bbcode_text = "[center][color=lime]+HEALTH"
	label_idx = wrapi(label_idx + 1, 0, LabelPool.size())

func _on_PauseMessage_on_pause():
	n_Dialog.visible = !n_Dialog.visible

func _on_AnimationPlayer_animation_finished(anim_name):
	
	match anim_name:
		"win_full_tank":
			var new_scene = load("res://scenes/World/WorldMap.tscn")
			get_tree().change_scene_to(new_scene)
