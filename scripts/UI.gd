extends CanvasLayer

onready var tween := Tween.new()
onready var color_rect := $ColorRectHitFX

func _ready():
	add_child(tween)
	tween.connect("tween_completed", self, "_on_Tween_completed")

func fade_in() -> void:
	color_rect.visible = true
	tween.interpolate_property(color_rect,"color",Color.transparent,Color.red,.05,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
	tween.start()

func fade_out() -> void:
	color_rect.visible = true
	tween.interpolate_property(color_rect,"color",Color.red,Color.transparent,.025,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
	tween.start()

func _on_Tween_completed(object, key) -> void:
	color_rect.visible = false

func _on_Player_on_hit():
	if tween.is_active():
		return
	fade_in()
	yield(tween,"tween_completed")
	fade_out()
