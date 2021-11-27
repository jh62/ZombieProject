extends Particles2D

export var lifetime_secs := 30

var elapsed : = 0.0

func _ready():
	z_index = 50

func _process(delta):
	if modulate.a <= 0.0:
		call_deferred("queue_free")
	if elapsed >= lifetime_secs:
		modulate.a -= .01
	elapsed += delta


func _on_VisibilityNotifier2D_viewport_entered(viewport):
	emitting = true

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	emitting = false
