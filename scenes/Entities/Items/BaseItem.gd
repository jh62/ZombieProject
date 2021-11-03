class_name BaseItem extends Sprite

signal on_use

onready var anim_p : AnimationPlayer = $AnimationPlayer

var equipper : Mobile
var in_use := false

# virtual methods
func get_item_name() -> String:
	return ""
func get_icon() -> Texture:
	return null

func _ready() -> void:
	EventBus.connect("action_pressed", self, "_on_action_pressed")
	EventBus.connect("action_released", self, "_on_action_released")

func _process(_delta: float) -> void:
	if equipper == null || !equipper.is_alive():
		return
	update_animations()

func update_animations() -> void:
	var state = equipper.fsm.current_state.get_name()
	var facing = equipper.facing

	var anim_name = state
	var anim_dir = Mobile.get_facing_as_string(facing)

	anim_p.play("{0}_{1}".format({0:anim_name,1:anim_dir}))
	self.flip_h = facing.x < 0

func _on_action_pressed(action_name, facing) -> void:
	pass

func _on_action_released(action_name, facing) -> void:
	pass

func _on_action_animation_started(anim_name, facing) -> void:
	pass

func _on_action_animation_finished(anim_name, facing) -> void:
	pass

func _on_animation_started(anim_name: String) -> void:
	var anim_data = anim_name.split("_")
	_on_action_animation_started(anim_data[0],anim_data[1])

func _on_animation_finished(anim_name: String) -> void:
	var anim_data = anim_name.split("_")
	_on_action_animation_finished(anim_data[0],anim_data[1])
