extends TextureProgress

signal on_progress_complete

export var fill_time := 5.0

func start() -> void:
	visible = true
	$AudioStreamPlayer.play()
	$Tween.interpolate_property(self, "value", min_value, max_value, fill_time,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.start()

func stop() -> void:
	$AudioStreamPlayer.stop()
	value = min_value
	visible = false
	$Tween.stop_all()

func _on_ProgressWheel_value_changed(value):
	if value >= max_value:
		visible = false
		emit_signal("on_progress_complete")
