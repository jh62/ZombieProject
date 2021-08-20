class_name BaseItem extends Sprite

onready var anim_p : AnimationPlayer = $AnimationPlayer
onready var audio_p : AudioStreamPlayer2D = $AudioStreamPlayer2D

var state : State
var facing : Vector2

func _ready() -> void:
	EventBus.connect("action_pressed", self, "_on_action_pressed")
	EventBus.connect("action_released", self, "_on_action_released")

func _process(delta: float) -> void:
	update_animations()

func update_animations() -> void:
	var anim_name = state.get_name()
	var anim_dir = Mobile.get_facing_as_string(facing)

	anim_p.play("{0}_{1}".format({0:anim_name,1:anim_dir}))
	self.flip_h = facing.x < 0

func _on_action_pressed(facing) -> void:
	pass

func _on_action_released(facing) -> void:
	pass

func _on_action_started(anim_name, facing) -> void:
	pass

func _on_action_finished(anim_name, facing) -> void:
	pass

func _on_animation_started(anim_name: String) -> void:
	var anim_data = anim_name.split("_")
	_on_action_started(anim_data[0],anim_data[1])

func _on_animation_finished(anim_name: String) -> void:
	var anim_data = anim_name.split("_")
	_on_action_finished(anim_data[0],anim_data[1])

