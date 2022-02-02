extends Control

onready var n_TabContainer := $TabContainer

func _unhandled_input(event):
	if !visible:
		return

	var current_tab : Control = n_TabContainer.get_current_tab_control()

	if current_tab.has_focus():
		if event.is_action_released("ui_left"):
			n_TabContainer.current_tab = wrapi(n_TabContainer.current_tab - 1, 0, 3)
		elif event.is_action_released("ui_right"):
			n_TabContainer.current_tab = wrapi(n_TabContainer.current_tab + 1, 0, 3)

		n_TabContainer.get_current_tab_control().grab_focus()

func _on_OptionsMenu_visibility_changed():
	if visible:
		$TabContainer/Gameplay.grab_focus()

func _on_TabContainer_focus_entered():
	var tab = n_TabContainer.get_tab_title(n_TabContainer.current_tab)
	var child

	match tab:
		"Gameplay":
			child = $TabContainer/Gameplay.get_node("Grid/CheckBoxJoypad")
		"Graphics":
			child = $TabContainer/Graphics.get_node("ScrollContainer/VBoxContainer/Option7/CheckBoxRenderNoise")
		"Audio":
			child = $TabContainer/Audio.get_node("VBoxContainer/Option3/SliderZombieFootsteps")

	if child:
		child.grab_focus()
