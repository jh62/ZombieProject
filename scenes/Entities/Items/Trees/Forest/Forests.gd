extends YSort

func set_shapes_disabled(disabled : bool) -> void:
	for c in get_children():
		if c is TreeEntity:
			var shape = c.get_node("CollisionShape2D")
			if shape != null:
				shape.disabled = disabled
			c.set_process(false)
			c.set_physics_process(false)
			c.set_process_internal(false)
			c.set_process_input(false)
			visible = !disabled

func _on_VisibilityEnabler2D_screen_entered():
	set_shapes_disabled(false)

func _on_VisibilityEnabler2D_screen_exited():
	set_shapes_disabled(true)

func _on_Area2D_body_entered(body):
	for c in get_children():
		if c is TreeEntity:
			c.set_light_mask(0)


func _on_Area2D_body_exited(body):
	for c in get_children():
		if c is TreeEntity:
			c.set_light_mask(16)
