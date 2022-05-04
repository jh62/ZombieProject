extends StaticObject


func _ready():
	pass # Replace with function body.
	
func on_hit_by(attacker) -> void:
	pass
#	if attacker is Projectile:
#		var explosion := preload("res://scenes/Entities/Explosion/Explosion.tscn").instance() as Explosion
#		add_child(explosion)
#		explosion.create_big_explosion(48)
#		explosion.global_position = global_position + Vector2(0, $Sprite.region_rect.size.y - 6)
