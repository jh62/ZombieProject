extends CanvasLayer

#func _notification(what):
#	if what == NOTIFICATION_PARENTED:
#		$Label/AnimationPlayer.play("loot")
#		print_debug("ready")

func _on_AnimationPlayer_animation_finished(anim_name):
	get_parent().remove_child(self)

func _on_CanvasLayer_tree_entered():
	$Label/AnimationPlayer.play("loot")
