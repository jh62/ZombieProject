extends Sprite

func _ready():
	visible = false
	set_process(false)
	set_physics_process(false)

func show() -> void:
	visible = true
	$Light2D.enabled = true
	$Timer.start()

func _on_Timer_timeout():
	visible = false
	$Light2D.enabled = false
