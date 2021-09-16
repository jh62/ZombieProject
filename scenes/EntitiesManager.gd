extends YSort

signal on_mob_spawned(mob)

const Bullet := preload("res://scenes/Entities/Items/Projectile/Projectile.tscn")
const Zombie := preload("res://scenes/Entities/Mobiles/Zombie/Zombie.tscn")

func _ready() -> void:
	EventBus.connect("on_bullet_spawn", self, "_on_bullet_spawn")
	EventBus.connect("on_mob_spawn", self, "_on_mob_spawn")
	EventBus.connect("on_object_spawn", self, "_on_object_spawn")

func _on_bullet_spawn(position, damage, knockback := 0.0, direction = null ) -> void:
	var bullet : Projectile = Bullet.instance()
	add_child(bullet)

	if direction == null:
		direction = position.direction_to(get_global_mouse_position())

	bullet.linear_velocity = Vector2(direction.x, direction.y) * 500
	bullet.global_position = position
	bullet.look_at(position + (direction * 500))
	bullet.damage = damage
	bullet.knockback = knockback

func _on_mob_spawn(position) -> void:
	var zombie : Mobile = Zombie.instance()
	zombie.global_position = position
	zombie.visible = false
	yield(get_tree().create_timer(.05),"timeout")
	if zombie.get_slide_count() > 0:
		zombie.queue_free()
		return

	zombie.visible = true
	add_child(zombie)
	emit_signal("on_mob_spawned", zombie)

func _on_object_spawn(scene : PackedScene, position : Vector2) -> void:
	var obj := scene.instance()
	obj.global_position = position
	$StaticOBjects.add_child(obj)
