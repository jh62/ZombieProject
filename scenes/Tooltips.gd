extends RichTextLabel

func _ready():
	EventBus.connect("on_tooltip", self, "_on_tooltip")
	EventBus.connect("on_player_death", self, "_on_player_death")
	
func _on_player_death(player) -> void:
	visible = false

func _on_tooltip(_text : String) -> void:
	visible = !_text.empty()

	if !visible:
		return

	bbcode_text = "[center]" + _text + "[/center]"
