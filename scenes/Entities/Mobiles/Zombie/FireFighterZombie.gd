class_name FireFighterZombie extends Zombie

func _ready():
	sounds["ext_hit"] = [preload("res://assets/sfx/mobs/zombie/misc/firefighter_ext_hit.wav")]
	sounds["axe_hit"] = [preload("res://assets/sfx/mobs/zombie/misc/firefighter_axe_hit.wav")]
	
func get_class():
	return "FireFighterZombie"
	
func on_hit_by(attacker) -> void:
	.on_hit_by(attacker)
	
	hitpoints -=  attacker.damage
	
	if attacker is Projectile:
		var attacker_dir = attacker.linear_velocity.normalized().dot(dir)
		
		if attacker_dir >= 0:
			if !$Particles2D.emitting:
				$Particles2D.emitting = true
				$TimerExtinguisher.start()
				EventBus.emit_signal("play_sound_random", sounds.ext_hit, global_position)
			else:
				var exlp := preload("res://scenes/Entities/Explosion/Explosion.tscn").instance()
				add_child(exlp)
				exlp.create_small_explosion(2.0, 1.0)

	var new_state : State

	if !is_alive():
		down_times += 1
		fsm.travel_to(states.die, null)
		return
	
	fsm.travel_to(states.hit, {
		"attacker": attacker
	})
