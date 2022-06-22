extends Control

const MainScene := preload("res://scenes/Main.tscn")
const ShopScene := preload("res://scenes/UI/Shop/UIShop.tscn")

onready var n_AnimPlayer := $AnimationPlayer
onready var n_Path2DFollow := $Path2D/PathFollow2D2
onready var n_ConfirmDialog := $CanvasLayer/CenterContainer/OptionButton

func _ready():
	var current_level = PlayerStatus.current_level
	n_AnimPlayer.play("path_{0}".format({0:current_level}))
	n_ConfirmDialog.get_cancel().connect("button_up", self, "_on_OptionButton_canceled")

func _process(delta):
	n_Path2DFollow.unit_offset = $Path2D/PathFollow2D.unit_offset

func _on_AnimationPlayer_animation_finished(anim_name : String):
	if anim_name.begins_with("path"):
		n_AnimPlayer.play("transition")
	elif anim_name.begins_with("transition"):
		n_ConfirmDialog.show()#
	
func _on_OptionButton_confirmed():
	get_tree().change_scene_to(ShopScene)
	call_deferred("queue_free")

func _on_OptionButton_canceled():
	get_tree().change_scene_to(MainScene)
	call_deferred("queue_free")
