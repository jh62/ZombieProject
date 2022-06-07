extends Sprite

func _ready():
	frame = randi() % (hframes * vframes)
	modulate.a = 1.0
	$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 15.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func _on_VisibilityNotifier2D_screen_exited():
	if get_parent() != null:
		get_parent().call_deferred("remove_child", self)
