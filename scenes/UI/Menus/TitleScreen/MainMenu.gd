extends MarginContainer

func _ready():
	pass

func _on_MainMenu_visibility_changed():
	if !visible:
		return
	$CenterContainer/VBoxContainer/ButtonNew.grab_focus()
