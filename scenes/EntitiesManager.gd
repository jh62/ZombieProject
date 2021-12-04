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
	EventBus.connect("on_weapon_reloaded", self, "_on_weapon_reloaded")

func _spawn_bullet(position, damage, knockback := 0.0, aimed := false) -> void:
	var bullet : Projectile = Bullet.instance()

	var target_pos := get_global_mouse_position()

	if !aimed:
		var precision_margin := PlayerStatus.precision_margin_error
		target_pos += Vector2(rand_range(-precision_margin,precision_margin),rand_range(-precision_margin,precision_margin))

	var direction = position.direction_to(target_pos)

	bullet.linear_velocity = Vector2(direction.x, direction.y) * 500
	bullet.damage = damage
	bullet.knockback = knockback

	bullet.global_position = position

	n_Mobs.add_child(bullet)
	bullet.look_at(position + direction)

var bad_spawns := [] # lazy fix

func _spawn_mob(position) -> void:
	var zombie : Mobile
	zombie = Zombie.instance()

	if bad_spawns.empty():
		zombie = Zombie.instance()
	else:
		zombie = bad_spawns.pop_back()

	n_Mobs.add_child(zombie)

	# Check if spot is valid
	zombie.move_and_slide(Vector2.ZERO)

	if zombie.get_slide_count() > 0:
		var collision := zombie.get_slide_collision(0)
		if collision.collider is StaticObject:
			bad_spawns.append(zombie)
			print_debug("bad spot")
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

func _on_weapon_reloaded(weapon_name):
	var mag := Magazine.instance() as RigidBody2D
	mag.set_type(weapon_name)
	n_Statics.add_child(mag)
	mag.global_position = n_Mobs.get_node("Player").global_position
