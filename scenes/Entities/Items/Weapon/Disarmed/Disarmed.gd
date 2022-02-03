extends BaseWeapon

func get_weapon_type():
	return Globals.WeaponNames.DISARMED

func _on_action_pressed(action_type, facing) -> void:
	pass

func _on_action_released(action_type : int, facing) -> void:
	pass

func _on_action_animation_started(anim_name, facing) -> void:
	pass
