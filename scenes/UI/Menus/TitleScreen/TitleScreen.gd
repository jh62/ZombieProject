extends Control

var loader : ResourceInteractiveLoader

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
	$MarginContainer2.visible = false
	$ActiveMenu/MarginContainer.visible = false
	loader = ResourceLoader.load_interactive("res://scenes/Main.tscn")
