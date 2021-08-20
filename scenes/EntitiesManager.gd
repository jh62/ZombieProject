extends YSort


func _ready() -> void:
	EventBus.connect("on_bullet_spawn", self, "_on_bullet_spawn")

var Bullet := preload("res://scenes/Items/Projectile/Projectile.tscn")

func _on_bullet_spawn(position, direction) -> void:
	var bullet : RigidBody2D = Bullet.instance()
	bullet.linear_velocity = Vector2(direction.x, direction.y) * 500
	bullet.global_position = position
	bullet.look_at(position + (direction * 500))
	add_child(bullet)
