extends Control

var loader := ResourceInteractiveLoader.new()
var last_poll := 0.0
var resource

func _ready():
	pass

func _process(time):
	if loader == null:
		return

	var now := OS.get_ticks_msec()

	if now - last_poll < randi() % 50 + 25:
		return

	last_poll = now
	var err = loader.poll()

	if err == ERR_FILE_EOF: # Finished loading.
		resource = loader.get_resource()
		loader = null
		$AnimationPlayer.play("outro")
	elif err == OK:
		pass
	else: # Error during loading.
		loader = null

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"intro":
			loader = ResourceLoader.load_interactive("res://scenes/UI/Menus/TitleScreen/TitleScreen.tscn")
		"outro":
			get_tree().change_scene_to(resource)
			get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, Vector2(320,180),1)
			call_deferred("queue_free")
