extends YSort

signal on_mob_spawned(mob)

const Bullet := preload("res://scenes/Entities/Items/Projectile/Projectile.tscn")
const Zombie := preload("res://scenes/Entities/Mobiles/Zombie/Zombie.tscn")
const Explosion := preload("res://scenes/Entities/Explosion/Explosion.tscn")
const Magazine := preload("res://scenes/Entities/Items/Magazine/Magazine.tscn")

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

	if n_Mobs.get_node("Player").aiming:
		print_debug("aminig")
		bullet.set_collision_mask_bit(2, false)

	bullet.global_position = position
	bullet.look_at(position + (direction * 500))

func _spawn_mob(position) -> void:

	var zombie : Mobile = Zombie.instance()
	n_Mobs.add_child(zombie)

	# Check if spot is valid
	zombie.move_and_slide(Vector2.ZERO)

	if zombie.get_slide_count() > 0:
		var collision := zombie.get_slide_collision(0)
		if collision.collider is StaticObject:
			zombie.queue_free()
			return

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

func _on_Player_on_reload(weapon_name):
	var mag := Magazine.instance() as RigidBody2D
	mag.set_type(weapon_name)
	n_Statics.add_child(mag)
	mag.global_position = n_Mobs.get_node("Player").global_position
