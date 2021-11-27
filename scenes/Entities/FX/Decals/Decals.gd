extends AnimatedSprite

const LIFETIME_SECS := 15.0
var elapsed := 0.0

func _ready():
	var anim_name := "decal_1"

	for a in frames.get_animation_names():
		if .5 > randf():
			anim_name = a
			break

	play(anim_name)

func _process(delta):
	if elapsed >= LIFETIME_SECS:
		if modulate.a <= 0.0:
			queue_free()
		else:
			modulate.a -= .05

	elapsed += delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
