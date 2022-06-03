class_name StaticObject extends StaticBody2D

enum MaterialType {
	METAL,
	WOOD,
	GLASS,
	CEMENT,
	FLESH,
}

export var max_hitpoints := 100.0

const hit_sounds := {
	MaterialType.METAL: [
		preload("res://assets/sfx/impact/bullet_metal_1.wav"),
		preload("res://assets/sfx/impact/bullet_metal_2.wav"),
		preload("res://assets/sfx/impact/bullet_metal_3.wav"),
		preload("res://assets/sfx/impact/bullet_metal_4.wav"),
	],
	MaterialType.GLASS: [
		preload("res://assets/sfx/impact/bullet_glass_1.wav"),
		preload("res://assets/sfx/impact/bullet_glass_2.wav"),
		preload("res://assets/sfx/impact/bullet_glass_3.wav"),
		preload("res://assets/sfx/impact/bullet_glass_4.wav"),
	],
	MaterialType.WOOD: [
		preload("res://assets/sfx/impact/bullet_wood_1.wav"),
		preload("res://assets/sfx/impact/bullet_wood_2.wav"),
		preload("res://assets/sfx/impact/bullet_wood_3.wav"),
		preload("res://assets/sfx/impact/bullet_wood_4.wav"),
	],
	MaterialType.CEMENT: [
		preload("res://assets/sfx/impact/bullet_concrete_1.wav"),
		preload("res://assets/sfx/impact/bullet_concrete_2.wav"),
		preload("res://assets/sfx/impact/bullet_concrete_3.wav"),
		preload("res://assets/sfx/impact/bullet_concrete_4.wav"),
	],
	MaterialType.FLESH: [
		preload("res://assets/sfx/impact/flesh_impact_1.wav"),
		preload("res://assets/sfx/impact/flesh_impact_2.wav"),
	]
}

export(MaterialType) var material_type := MaterialType.CEMENT

onready var n_sprite := $Sprite
onready var n_Area2d := $Area2D
onready var n_Collision := $CollisionShape

var hitpoints := 0 setget set_hitpoints

# virtual methods
func on_search_successful() -> void:
	pass

func _ready():
	hitpoints = max_hitpoints

	if has_node("$Sprite/LightOccluder2D"):
		$Sprite/LightOccluder2D.visible = true

	yield(get_tree().create_timer(.25),"timeout")

	if is_instance_valid(self) && $Area2D/CollisionShapeArea.polygon == null:
		var poly = $CollisionShape.get_polygon()
		$Area2D/CollisionShapeArea.set_polygon(poly)
		$Area2D.position += Vector2.UP * 4

func _process(delta):
	pass

func on_hit_by(attacker) -> void:
	if attacker is Projectile:
		self.hitpoints -= attacker.damage
		var snd = hit_sounds.get(material_type)
		EventBus.emit_signal("play_sound_random", snd, global_position, rand_range(.95, 1.06), 0.0)

func _on_body_entered(body : Node2D):
	n_sprite.self_modulate.a = .35
	
	if has_node("SpriteTop"):
		get_node("SpriteTop").self_modulate.a = .35

func _on_body_exited(body):
	if n_Area2d.get_overlapping_bodies().size() == 0:		
		n_sprite.self_modulate.a = 1.0
		
		if has_node("SpriteTop"):
			get_node("SpriteTop").self_modulate.a = 1.0

func _on_VisibilityNotifier2D_screen_entered():
	set_process(true)
	set_physics_process(true)
	n_Area2d.monitorable = true
	n_Area2d.monitorable = true
	n_Collision.disabled = false

func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)
	set_physics_process(false)
	n_Area2d.monitorable = false
	n_Area2d.monitorable = false
	n_Collision.disabled = true

func set_hitpoints(value) -> void:
	hitpoints = clamp(value, 0.0, max_hitpoints)
