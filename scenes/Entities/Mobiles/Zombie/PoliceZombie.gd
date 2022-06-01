class_name PoliceZombie extends Zombie

func _ready():
	sounds["vest"] = [
		preload("res://assets/sfx/impact/kevlar_impact_1.wav"),
		preload("res://assets/sfx/impact/kevlar_impact_2.wav"),
		preload("res://assets/sfx/impact/kevlar_impact_3.wav")
	]

func get_class():
	return "PoliceZombie"
	
func on_hit_by(attacker) -> void:
	var dam = attacker.damage
	
	if attacker is Projectile:
		var attacker_dir = attacker.linear_velocity.normalized().dot(dir)
		
		if attacker_dir < 0:
			EventBus.emit_signal("play_sound_random", sounds.vest, global_position)
			dam *= .25
		else:
			dam *= 1.5
			.on_hit_by(attacker)
			
	hitpoints -=  dam
	
	if !is_alive():
		fsm.travel_to(states.die, null)
		return
		
	fsm.travel_to(states.hit,{
		"attacker": attacker
	})
