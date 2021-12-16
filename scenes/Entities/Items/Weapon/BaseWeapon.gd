class_name BaseWeapon extends BaseItem

export var damage := 0.0
export var knockback := 0.0
export var fire_rate := 0.0

# Virtual methods
func get_weapon_type():
	pass
func get_sound_shoot():
	pass

func _ready():
	pass

func _on_action_pressed(action_type, facing) -> void:
	match action_type:
		EventBus.ActionEvent.USE:
			in_use = true

func _on_action_released(action_type : int, facing) -> void:
	if in_use:
		yield(anim_p,"animation_finished")
	in_use = false

func update_animations() -> void:
	if equipper == null:
		return

	var state = equipper.fsm.current_state
	var facing = equipper.facing

	var state_name =  state.get_name()
	var facing_name = Mobile.get_facing_as_string(facing)
	var anim_name = "{0}_{1}".format({0:state_name,1:facing_name})

	if !anim_p.has_animation(anim_name):
		return

	self.flip_h = facing.x < 0

	if in_use:
		if anim_p.current_animation.begins_with("shoot"):
			return
		anim_name = "shoot_{0}".format({0:facing_name})
		anim_p.playback_speed = fire_rate
	else:
		anim_p.playback_speed = 1.0

	anim_p.play(anim_name)

func _on_action_animation_started(anim_name, facing) -> void:
	match anim_name:
		"shoot":
			var snd = get_sound_shoot()
			emit_signal("on_use")
			EventBus.emit_signal("play_sound_random", snd, global_position)
