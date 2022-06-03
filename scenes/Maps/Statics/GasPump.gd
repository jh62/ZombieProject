extends StaticObject

var exploded := false

func get_item_name():
	return "fuel pump"

func on_hit_by(attacker) -> void:
	if exploded:
		return

	.on_hit_by(attacker)

	if hitpoints <= 0:
		var explosion := preload("res://scenes/Entities/Explosion/Explosion.tscn").instance() as Explosion
		add_child(explosion)
		explosion.create_big_explosion(48)
		explosion.global_position = global_position + Vector2(0, $Sprite.region_rect.size.y - 6)
		explosion.connect("explosion_complete", self, "on_explosion_completed")

		exploded = true
		set_collision_mask_bit(6, false)
		$Sprite.visible = false

		yield(get_tree().create_timer(.25),"timeout")
		var smoke := preload("res://scenes/Entities/FX/Smoke/Smoke.tscn").instance()
		EventBus.emit_signal("on_object_spawn", smoke, global_position)

func on_explosion_completed() -> void:
	queue_free()
