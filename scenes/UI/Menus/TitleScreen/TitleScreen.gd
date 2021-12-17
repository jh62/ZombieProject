extends Control

enum MenuScreen {
	EMPTY = -1,
	MAIN,
	OPTIONS
}

export var parallax_speed := 200.0

onready var Menus := {
	MenuScreen.MAIN: $ActiveMenu/MainMenu,
	MenuScreen.OPTIONS: $ActiveMenu/OptionsMenu,
}

# Gameplay controls
onready var n_OptionsDifficulty := $ActiveMenu/OptionsMenu/TabContainer/Gameplay/Grid/OptionsDifficulty
onready var n_CheckBoxAutopick := $ActiveMenu/OptionsMenu/TabContainer/Gameplay/Grid/CheckBoxAutoPickup
onready var n_CheckBoxRealMags := $ActiveMenu/OptionsMenu/TabContainer/Gameplay/Grid/CheckBoxRealMags
onready var n_CheckBoxDeathWish := $ActiveMenu/OptionsMenu/TabContainer/Gameplay/Grid/CheckBoxDeathWish
# Graphics controls
onready var n_CheckBoxRenderBullets := $ActiveMenu/OptionsMenu/TabContainer/Graphics/ScrollContainer/VBoxContainer/Option1/CheckBoxRenderBullets
onready var n_CheckBoxRenderMags := $ActiveMenu/OptionsMenu/TabContainer/Graphics/ScrollContainer/VBoxContainer/Option2/CheckBoxRenderMags
onready var n_CheckBoxRenderBlood := $ActiveMenu/OptionsMenu/TabContainer/Graphics/ScrollContainer/VBoxContainer/Option3/CheckBoxRenderBlood
onready var n_CheckBoxCorpseDecay := $ActiveMenu/OptionsMenu/TabContainer/Graphics/ScrollContainer/VBoxContainer/Option4/CheckBoxCorpseDecay
onready var n_CheckBoxRenderMist := $ActiveMenu/OptionsMenu/TabContainer/Graphics/ScrollContainer/VBoxContainer/Option5/CheckBoxRenderMist
onready var n_CheckBoxRenderVignette := $ActiveMenu/OptionsMenu/TabContainer/Graphics/ScrollContainer/VBoxContainer/Option6/CheckBoxRenderVignette
onready var n_CheckBoxRenderNoise := $ActiveMenu/OptionsMenu/TabContainer/Graphics/ScrollContainer/VBoxContainer/Option7/CheckBoxRenderNoise
# Audio controls
onready var n_SliderMusic := $ActiveMenu/OptionsMenu/TabContainer/Audio/VBoxContainer/Option1/SliderMusic
onready var n_SliderSound := $ActiveMenu/OptionsMenu/TabContainer/Audio/VBoxContainer/Option4/SliderSound
onready var n_SliderPlayerFootsteps := $ActiveMenu/OptionsMenu/TabContainer/Audio/VBoxContainer/Option2/SliderPlayerFootsteps
onready var n_SliderZombieFootsteps := $ActiveMenu/OptionsMenu/TabContainer/Audio/VBoxContainer/Option3/SliderZombieFootsteps
var loader : ResourceInteractiveLoader
var current_menu = MenuScreen.MAIN setget set_menu_screen

func _ready():
	pass

func _process(time):
	if loader == null:
		return

	var err = loader.poll()

	if err == ERR_FILE_EOF: # Finished loading.
		var resource = loader.get_resource()
		loader = null
		set_new_scene(resource)
	elif err == OK:
		update_progress()
	else: # Error during loading.
		print_debug("ERROR")
		loader = null

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	$Progress.value = progress

func set_new_scene(scene_resource):
	get_tree().change_scene_to(scene_resource)
	set_process(false)

func _on_ButtonNew_button_up():
	$Progress.visible = true
	$Progress.value = 0.0
	set_menu_screen(MenuScreen.EMPTY)
	loader = ResourceLoader.load_interactive("res://scenes/Main.tscn")

func _on_ButtonOptions_button_up():
	set_menu_screen(MenuScreen.OPTIONS)
	$CanvasLayer/Graphics.modulate.a = .25

func _on_ButtonExit_button_up():
	get_tree().quit()

func save() -> void:
	# Gameplay
	Global.GameOptions.gameplay.difficulty = Globals.Difficulty.values()[n_OptionsDifficulty.selected]
	Global.GameOptions.gameplay.discard_bullets = n_CheckBoxRealMags.pressed
	Global.GameOptions.gameplay.death_wish = n_CheckBoxDeathWish.pressed
	Global.GameOptions.gameplay.auto_pickup = n_CheckBoxAutopick.pressed
	# Graphics
	Global.GameOptions.graphics.render_blood = n_CheckBoxRenderBlood.pressed
	Global.GameOptions.graphics.render_bullets = n_CheckBoxRenderBullets.pressed
	Global.GameOptions.graphics.render_mags = n_CheckBoxRenderMags.pressed
	Global.GameOptions.graphics.render_mist = n_CheckBoxRenderMist.pressed
	Global.GameOptions.graphics.render_noise = n_CheckBoxRenderNoise.pressed
	Global.GameOptions.graphics.render_vignette = n_CheckBoxRenderVignette.pressed
	# Audio
	Global.GameOptions.audio.music_db = n_SliderMusic.value
	Global.GameOptions.audio.sound_db = n_SliderSound.value
	Global.GameOptions.audio.player_footsteps = n_SliderPlayerFootsteps.value
	Global.GameOptions.audio.zombie_footsteps = n_SliderZombieFootsteps.value

func set_menu_screen(new_value) -> void:
	current_menu = new_value

	for key in Menus:
		var menu = Menus[key]
		menu.visible = key == new_value

func _on_ButtonSave_button_up():
	save()
	set_menu_screen(MenuScreen.MAIN)
	$CanvasLayer/Graphics.modulate.a = 1.0

func _on_ButtonCancel_button_up():
	set_menu_screen(MenuScreen.MAIN)
	$CanvasLayer/Graphics.modulate.a = 1.0
