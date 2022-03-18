extends StaticObject

onready var sprite_top := $SpriteTop
onready var occluder := $Sprite/LightOccluder2D

func _on_body_entered(body : Node2D):
	print_debug(body.dir.y)
	if body.dir.y < 0:
		sprite_top.self_modulate.a = .75
		sprite_top.z_index = 1
		sprite_top.light_mask =  sprite_top.light_mask & ~(1 << 1)
		occluder.occluder.cull_mode = OccluderPolygon2D.CULL_COUNTER_CLOCKWISE

func _on_body_exited(body):
	if body.dir.y > 0:
		sprite_top.self_modulate.a = 1.0
		sprite_top.z_index = 0
		sprite_top.light_mask =  sprite_top.light_mask | (1 << 1)
		occluder.occluder.cull_mode = OccluderPolygon2D.CULL_CLOCKWISE
