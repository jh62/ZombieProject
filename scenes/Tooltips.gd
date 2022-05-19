extends RichTextLabel

func _ready():
	EventBus.connect("on_tooltip", self, "_on_tooltip")

func _on_tooltip(_text : String) -> void:
	visible = !_text.empty()

	if !visible:
		return

	bbcode_text = "[center]" + _text + "[/center]"
