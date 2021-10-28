class_name StaticObject extends StaticBody2D

onready var n_sprite := $Sprite

# virtual methods
func on_search_successful() -> void:
	pass

func _ready():
	$Sprite/LightOccluder2D.visible = true
	set_physics_process(false)
	yield(get_tree().create_timer(.25),"timeout")

	if $Area2D/CollisionShapeArea.polygon == null:
		var poly = $CollisionShape.get_polygon()
		$Area2D/CollisionShapeArea.set_polygon(poly)
		$Area2D.position += Vector2.UP * 4

func _on_body_entered(body):
	n_sprite.self_modulate.a = .77

func _on_body_exited(body):
	n_sprite.self_modulate.a = 1.0

func _on_VisibilityNotifier2D_screen_entered():
	set_process(false)
	set_physics_process(false)
	$Area2D.monitorable = false
	$Area2D.monitorable = false

func _on_VisibilityNotifier2D_screen_exited():
	set_process(true)
	set_physics_process(true)
	$Area2D.monitorable = true
	$Area2D.monitorable = true
