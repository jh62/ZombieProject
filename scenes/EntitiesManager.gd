extends YSort

signal on_mob_spawned(mob)

const Bullet := preload("res://scenes/Entities/Items/Projectile/Projectile.tscn")
const Zombie := preload("res://scenes/Entities/Mobiles/Zombie/Zombie.tscn")
const Explosion := preload("res://scenes/Entities/Explosion/Explosion.tscn")

onready var n_Statics := $Statics
onready var n_Mobs := $Mobs

func _ready() -> void:
	EventBus.connect("on_bullet_spawn", self, "_spawn_bullet")
	EventBus.connect("on_mob_spawn", self, "_spawn_mob")
	EventBus.connect("on_object_spawn", self, "_spawn_object")

func _spawn_bullet(position, damage, knockback := 0.0, direction = null ) -> void:
	var bullet : Projectile = Bullet.instance()
	n_Mobs.add_child(bullet)

	if direction == null:
		direction = position.direction_to(get_global_mouse_position())

	bullet.linear_velocity = Vector2(direction.x, direction.y) * 500
	bullet.damage = damage
	bullet.knockback = knockback

	bullet.global_position = position
	bullet.look_at(position + (direction * 500))

func _spawn_mob(position) -> void:
	var zombie : Mobile = Zombie.instance()
	n_Mobs.add_child(zombie)
	zombie.nav = get_parent().get_node("Navigation2D")
	zombie.global_position = position
	zombie.speed = rand_range(10,20)

	if .07 > randf():
		zombie.fsm.travel_to(ZombieRestState.new(zombie))

	emit_signal("on_mob_spawned", zombie)

func _spawn_object(scene, position : Vector2) -> void:
	if scene is PackedScene:
		scene = scene.instance()
	n_Statics.add_child(scene)
	scene.global_position = position
