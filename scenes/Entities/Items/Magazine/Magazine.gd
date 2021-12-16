extends RigidBody2D

func _ready():
	apply_impulse(Vector2.ZERO, Vector2(rand_range(-25,25), rand_range(-15,-17)))

func set_type(weapon_type) -> void:
	match weapon_type:
		Globals.WeaponNames.PISTOL, Globals.WeaponNames.SMG:
			$Sprite.texture = preload("res://assets/res/weapon/icons/magazine.tres")
		Globals.WeaponNames.SHOTGUN:
			$Sprite.texture = preload("res://assets/res/weapon/icons/slug.tres")
		Globals.WeaponNames.RIFLE:
			$Sprite.texture = preload("res://assets/res/weapon/icons/rifle_mag.tres")


func _on_VisibilityNotifier2D_screen_exited():
	call_deferred("queue_free")

func _on_Timer_timeout():
	modulate.a -= .05
	if modulate.a <= 0.0:
		call_deferred("queue_free")
