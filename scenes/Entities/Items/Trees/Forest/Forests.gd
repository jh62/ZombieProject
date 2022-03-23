extends YSort

func set_shapes_disabled(disabled : bool) -> void:
	for c in get_children():
		if c is StaticBody:
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
