extends YSort

const Decal := preload("res://scenes/Entities/FX/Decals/Decals.tscn")
const Blood := preload("res://scenes/Entities/FX/Blood/Blood.tscn")
const Bullet := preload("res://scenes/Entities/Items/Projectile/Projectile.tscn")

const Zombie := preload("res://scenes/Entities/Mobiles/Zombie/Zombie.tscn")
const Crawler := preload("res://scenes/Entities/Mobiles/Crawler/Crawler.tscn")
const Explosion := preload("res://scenes/Entities/Explosion/Explosion.tscn")
const Magazine := preload("res://scenes/Entities/Items/Magazine/Magazine.tscn")

onready var n_Ground := $Ground
onready var n_Statics := $Statics
onready var n_Mobs := $Mobs

var pool_decals := []
var pool_blood := []
var pool_bullets := []

var decal_idx := 0
var blood_idx := 0
var bullet_idx := 0

func _ready() -> void:
	EventBus.connect("on_bullet_spawn", self, "_on_bullet_spawn")
	EventBus.connect("spawn_blood", self, "_spawn_blood")
	EventBus.connect("spawn_decal", self, "_spawn_decal")
	EventBus.connect("on_mob_spawn", self, "_spawn_mob")
	EventBus.connect("on_object_spawn", self, "_spawn_object")
	EventBus.connect("on_weapon_reloaded", self, "_on_weapon_reloaded")

	for i in 20:
		var bullet := Bullet.instance()
		pool_bullets.append(bullet)
	
	for i in 50:
		var decal := Decal.instance()
		pool_decals.append(decal)
	
	for i in 20:
		var blood := Blood.instance()
		pool_blood.append(blood)

func _spawn_blood(position : Vector2) -> void:
	var blood = pool_blood[blood_idx]
			
	if blood.get_parent() != n_Ground:
		n_Ground.add_child(blood)
		
	blood.global_position = position
	blood_idx = wrapi(blood_idx + 1, 0, pool_blood.size())

func _spawn_decal(position) -> void:
	var decal = pool_decals[decal_idx]
	
	if decal.get_parent() != n_Ground:
		n_Ground.add_child(decal)
		
	decal.global_position = position
	decal_idx = wrapi(decal_idx + 1, 0, pool_decals.size())

func _on_bullet_spawn(position, damage, knockback := 0.0, aimed := false, type := 0) -> void:
	var target_pos : Vector2
	var direction : Vector2
	var precision : Vector2
	
	if !aimed:
		var precision_margin := PlayerStatus.precision_margin_error
		precision.x = rand_range(-precision_margin,precision_margin)
		precision.y = rand_range(-precision_margin,precision_margin)

	if Global.GameOptions.gameplay.joypad:
		var player : Node2D = n_Mobs.get_node("Player")
		var crosshair := player.get_node("Crosshair")
		target_pos = crosshair.position + precision
		direction = player.get_global_transform_with_canvas().origin.direction_to(target_pos)
	else:
		target_pos = get_global_mouse_position()  + precision
		direction = position.direction_to(target_pos)

	direction = position.direction_to(target_pos)
	
	match type:
		Projectile.Type.BULLET:
			var bullet = pool_bullets[bullet_idx]
			bullet_idx = wrapi(bullet_idx + 1, 0, pool_bullets.size())
			_spawn_bullet(bullet, damage, knockback, position, direction)
		Projectile.Type.SHELL:
			var rot := -0.2
			
			for i in 8:
				var bullet = pool_bullets[bullet_idx]
				bullet_idx = wrapi(bullet_idx + 1, 0, pool_bullets.size())
				_spawn_bullet(bullet, damage, knockback, position, direction)
				
				if direction.x != 0.0:
					direction.x = direction.rotated(rot).x
					
				if direction.y != 0.0:
					direction.y = direction.rotated(rot).y
					
				rot += 0.074
				
func _spawn_bullet(bullet : Node2D, damage, knockback, position, direction) -> void:
	bullet.visible = true
	bullet.set_process(true)
	bullet.set_physics_process(true)
	
	bullet.damage = damage
	bullet.knockback = knockback
	bullet.visible = Global.GameOptions.graphics.render_bullets
	bullet.global_position = position
	bullet.linear_velocity = Vector2(direction.x, direction.y) * 500
	
	if !bullet.is_connected("on_impact", self, "_on_bullet_impact"):
		bullet.connect("on_impact", self, "_on_bullet_impact")
		
	if !bullet.is_connected("on_exit_screen", self, "_on_bullet_impact"):
		bullet.connect("on_exit_screen", self, "_on_bullet_impact")
	
	if !n_Mobs.is_a_parent_of(bullet):
		n_Mobs.add_child(bullet)
	
	bullet.look_at(position + direction)
	
func _on_bullet_impact(node : Node2D) -> void:
	node.visible = false
	node.set_process(false)
	node.set_physics_process(false)
#
	if node.is_connected("on_impact", self, "_on_bullet_impact"):
		node.disconnect("on_impact", self, "_on_bullet_impact")

	if node.is_connected("on_exit_screen", self, "_on_bullet_impact"):
		node.disconnect("on_exit_screen", self, "_on_bullet_impact")

	n_Mobs.call_deferred("remove_child", node)
#	n_Mobs.remove_child(node)

var bad_spawns := [] # lazy fix

func _spawn_mob(position) -> void:
	var _mob : Mobile

	if get_tree().get_nodes_in_group(Globals.GROUP_SPECIAL).size() < Global.MAX_SPECIAL_ZOMBIES && (.75 > randf()):
		_mob = Crawler.instance()
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
			_mob.fsm.travel_to(_mob.states.rest, null)

	EventBus.emit_signal("mob_spawned", _mob)

func _spawn_object(scene, position : Vector2, layer := 0) -> void:
	if scene is PackedScene:
		scene = scene.instance()

	if layer == -1:
		n_Ground.add_child(scene)
	else:
		n_Statics.add_child(scene)

	scene.global_position = position

func _on_weapon_reloaded(_weapon):
	var mag := Magazine.instance() as RigidBody2D
	mag.set_type(_weapon.get_weapon_type())
	n_Statics.add_child(mag)
	mag.global_position = n_Mobs.get_node("Player").global_position
