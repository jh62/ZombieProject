extends Sprite

export var duration := 0.167

func show() -> void:
	visible = true
#	$Light2D.enabled = true
	$Timer.start(duration)

func _on_Timer_timeout():
	visible = false
#	$Light2D.enabled = false
