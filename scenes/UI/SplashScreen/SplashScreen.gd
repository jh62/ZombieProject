extends Control

onready var logo := $TextureRect_Logo
onready var label := $CenterContainer/Label
onready var tween := $CenterContainer/Tween

func _ready():
	logo.modulate.a = 0.0
	label.modulate.a = 0.0
	label.visible = false

func _process(delta):
	if logo.modulate.a < 1.0:
		return

func set_logo_visibility(amount) -> void:
	logo.modulate.a = clamp(amount, 0.0, 1.0)

func on_finished_loading() -> void:
	label.visible = true
	tween.interpolate_property(label,"modulate",Color(1.0,1.0,1.0,0.0), Color(1.0,1.0,1.0,1.0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_Tween_tween_completed(object, key):
	if label.modulate.a >= 1.0:
		tween.interpolate_property(label,"modulate",Color(1.0,1.0,1.0,1.0), Color(1.0,1.0,1.0,0.0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	else:
		tween.interpolate_property(label,"modulate",Color(1.0,1.0,1.0,0.0), Color(1.0,1.0,1.0,1.0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
