extends TextureProgress

signal on_progress_complete

export var fill_time := 5.0
export var label_text := "" setget set_label_text

func start() -> void:
	visible = true
	$Label.visible = false
	$AudioStreamPlayer.play()

	$Tween.interpolate_property(self, "value", min_value, max_value, fill_time,Tween.TRANS_LINEAR,Tween.EASE_IN)

	if !$Label.text.empty():
		$Tween.interpolate_property($Label, "visible", false, true, .5,Tween.TRANS_LINEAR,Tween.EASE_IN)

	$Tween.start()

func _on_ProgressWheel_value_changed(value):

	if value > (max_value * .9):
		tint_progress = Color.green
	elif value > (max_value * .75):
		tint_progress = Color.yellowgreen
	elif value > (max_value * .5):
		tint_progress = Color.yellow
	elif value > (max_value * .25):
		tint_progress = Color.orange
	elif value > (max_value * .15):
		tint_progress = Color.orangered
	else:
		tint_progress = Color.red

	if value >= max_value:
		visible = false
		emit_signal("on_progress_complete")

func set_label_text(text) -> void:
	$Label.text = text

func stop() -> void:
	$AudioStreamPlayer.stop()
	value = min_value
	visible = false
	$Tween.stop_all()

func _on_Tween_tween_completed(object, key):
	if object == $Label && key == ":visible":
		$Tween.interpolate_property($Label, "visible", false, true, .5,Tween.TRANS_LINEAR,Tween.EASE_IN)
		$Tween.start()
