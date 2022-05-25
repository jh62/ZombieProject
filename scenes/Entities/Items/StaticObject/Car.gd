extends StaticObject

const MAX_WARNINGS := 30

var exploded = false

func _ready():
	$Sprite.frame = randi() % ($Sprite.hframes * $Sprite.vframes)

func get_item_name():
	return "vehicle"

func explode() -> void:
	if exploded:
		return

	hitpoints = 0
	exploded = true
	modulate = Color.white
	$Area2D.set_collision_mask_bit(5, false) # Bullets
	$SpriteDestroyed.visible = true

	set_process(false)
	set_physics_process(false)

	var search_area := find_node("SearchableArea*")

	if search_area:
		search_area.spawn_loot()
		search_area.call_deferred("queue_free")

	for c in get_children():
		if c.name.begins_with("TrailSmoke"):
			c.queue_free()

	var expl := preload("res://scenes/Entities/Explosion/Explosion.tscn").instance() as Explosion
	add_child(expl)
	expl.create_huge_explosion(24)
	expl.rotation_degrees = 180 if rotation_degrees != 0 else 0

func kill() -> void:
	explode()

func on_hit_by(attacker):
	.on_hit_by(attacker)

	if exploded:
		return

	if hitpoints > 0 && hitpoints < (max_hitpoints / 4):
		var smoke := preload("res://scenes/Entities/FX/TrailSmoke/TrailSmoke.tscn").instance()
		add_child(smoke)
		smoke.position += Vector2(rand_range(-8,8), rand_range(-2,2))

	if hitpoints <= 0:
		explode()

func find_trail():
	return find_node("TrailSmoke", true, false)

func _on_AreaGasCap_body_entered(body):
	explode()
