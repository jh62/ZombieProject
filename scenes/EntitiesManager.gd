extends YSort

signal on_mob_spawned(mob)

const BULLET_TYPE := {
	Projectile.Type.BULLET: preload("res://scenes/Entities/Items/Projectile/Projectile.tscn"),
	Projectile.Type.SHELL: preload("res://scenes/Entities/Items/Projectile/Shells/Shells.tscn")
}

const Zombie := preload("res://scenes/Entities/Mobiles/Zombie/Zombie.tscn")
const Crawler := preload("res://scenes/Entities/Mobiles/Crawler/Crawler.tscn")
const Explosion := preload("res://scenes/Entities/Explosion/Explosion.tscn")
const Magazine := preload("res://scenes/Entities/Items/Magazine/Magazine.tscn")

onready var n_Statics := $Statics
onready var n_Mobs := $Mobs

func _ready() -> void:
	EventBus.connect("on_bullet_spawn", self, "_spawn_bullet")
	EventBus.connect("on_mob_spawn", self, "_spawn_mob")
	EventBus.connect("on_object_spawn", self, "_spawn_object")
	EventBus.connect("on_weapon_reloaded", self, "_on_weapon_reloaded")

func _spawn_bullet(position, damage, knockback := 0.0, aimed := false, type := 0) -> void:
	var bullet = BULLET_TYPE.get(type, Projectile.Type.BULLET).instance()
	var target_pos : Vector2

	if Global.GameOptions.gameplay.joypad:
		var crosshair := n_Mobs.get_node("Player").get_node("Crosshair")
		target_pos = crosshair.position
	else:
		target_pos = get_global_mouse_position()

	if !aimed:
		var precision_margin := PlayerStatus.precision_margin_error
		target_pos += Vector2(rand_range(-precision_margin,precision_margin),rand_range(-precision_margin,precision_margin))
#
	var direction : Vector2
#
	if Global.GameOptions.gameplay.joypad:
		var player : Node2D = n_Mobs.get_node("Player")
		direction = player.get_global_transform_with_canvas().origin.direction_to(target_pos)
	else:
		direction = position.direction_to(target_pos)

	bullet.damage = damage
	bullet.knockback = knockback
	bullet.visible = Global.GameOptions.graphics.render_bullets
	bullet.global_position = position
	bullet.linear_velocity = Vector2(direction.x, direction.y) * 500
	bullet.look_at(position + direction)

	n_Mobs.add_child(bullet)

var bad_spawns := [] # lazy fix

func _spawn_mob(position) -> void:
	var _mob : Mobile

	if get_tree().get_nodes_in_group(Globals.GROUP_SPECIAL).size() < Global.MAX_SPECIAL_ZOMBIES && (.75 > randf()):
		_mob = Zombie.instance()
	else:
		if bad_spawns.empty():
			_mob = Zombie.instance()
		else:
			_mob = bad_spawns.pop_back()

	n_Mobs.add_child(_mob)

	# Check if spot is valid
	_mob.move_and_slide(Vector2.ZERO)

	if _mob.get_slide_count() > 0:
		var collision := _mob.get_slide_collision(0)
		if collision.collider is StaticObject:
			bad_spawns.append(_mob)
			return

	_mob.global_position = position

	if _mob.is_in_group(Global.GROUP_ZOMBIE):
		_mob.speed *= rand_range(1.0,1.5)
		if .07 > randf():
			_mob.fsm.travel_to(ZombieRestState.new(_mob))

	emit_signal("on_mob_spawned", _mob)

func _spawn_object(scene, position : Vector2) -> void:
	if scene is PackedScene:
		scene = scene.instance()
	n_Statics.add_child(scene)
	scene.global_position = position

func _on_weapon_reloaded(weapon_type):
	var mag := Magazine.instance() as RigidBody2D
	mag.set_type(weapon_type)
	n_Statics.add_child(mag)
	mag.global_position = n_Mobs.get_node("Player").global_position
