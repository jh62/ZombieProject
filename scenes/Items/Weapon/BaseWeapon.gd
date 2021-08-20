class_name BaseWeapon extends BaseItem

signal on_action_activated()

export var damage := 0.0
export var bullets := 0
export var mag_size := 0

var magazine := 0 setget set_magazine
var in_use := false # used when an item or weapon is actioned

func _process(delta: float) -> void:
	pass

func _on_action_pressed(facing) -> void:
	if magazine == 0:
		return
	in_use = true

func _on_action_released(facing) -> void:
	if in_use:
		yield(anim_p,"animation_finished")
	in_use = false

func set_magazine(val):
	magazine = clamp(val, 0, mag_size)

func update_animations() -> void:
	var anim_name : String =  state.get_name()
	var anim_dir = Mobile.get_facing_as_string(facing)

	if in_use:
		anim_name = "shoot"

	anim_p.play("{0}_{1}".format({0:anim_name,1:anim_dir}))
	self.flip_h = facing.x < 0

func _on_action_finished(anim_name, facing) -> void:
	match anim_name:
		"shoot":
			magazine -= 1
			emit_signal("on_action_activated")
			EventBus.emit_signal("on_bullet_spawn", global_position, self.facing)

			if magazine == 0:
				in_use = false

