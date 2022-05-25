extends Area2D

signal on_key_pickedup(keyid)

const KEY_SOUND := preload("res://assets/sfx/misc/keys_pickup.wav")

export var key_id := -1

func _ready():
	EventBus.connect("action_pressed", self, "on_action_pressed")

func on_action_pressed(event, facing):
	if event != EventBus.ActionEvent.USE_KEY:
		return
		
	if get_overlapping_bodies().empty():
		return
		
	var _owner = get_overlapping_bodies()[0]
	
	play_sound()
	
	get_parent().remove_child(self)
	_owner.add_child(self)
	emit_signal("on_key_pickedup", key_id)

func play_sound() -> void:
	EventBus.emit_signal("play_sound", KEY_SOUND, global_position)
	
func _on_Key_body_entered(body):
	if !EventBus.is_connected("action_pressed", self, "on_action_pressed"):
		EventBus.connect("action_pressed", self, "on_action_pressed")
	
	var button = InputMap.get_action_list("action_alt")[0].as_text()
	var _text = "Press [color=#fffc00]{0}[/color] to pickup the key".format({0:button})
	EventBus.emit_signal("on_tooltip", _text)

func _on_Key_body_exited(body):
	if EventBus.is_connected("action_pressed", self, "on_action_pressed"):
		EventBus.disconnect("action_pressed", self, "on_action_pressed")
	EventBus.emit_signal("on_tooltip", "")
