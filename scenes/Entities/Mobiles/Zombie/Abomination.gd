class_name Abomination extends BaseZombie

func _ready() -> void:
	add_to_group(Globals.GROUP_SPECIAL)
	
	states = {
		"idle": preload("res://scripts/fsm/states/zombie/ZombieIdleState.gd").new(self),
		"walk": preload("res://scripts/fsm/states/zombie/ZombieMoveState.gd").new(self),
		"attack": preload("res://scripts/fsm/states/zombie/ZombieAttackState.gd").new(self),
		"die": preload("res://scripts/fsm/states/zombie/ZombieDieState.gd").new(self),
		"hit": preload("res://scripts/fsm/states/abomination/AbominationHitState.gd").new(self),
	}

	sounds  = {
		"growl":[
			preload("res://assets/sfx/mobs/abomination/abomination_cry.wav")
		],
		"attack":[
			preload("res://assets/sfx/mobs/abomination/abomination_cry.wav")
		],
		"die":[
			preload("res://assets/sfx/mobs/abomination/abomination_die.wav")
		],
		"hurt":[
			preload("res://assets/sfx/mobs/abomination/abomination_hurt_1.wav"),
			preload("res://assets/sfx/mobs/abomination/abomination_hurt_2.wav"),
			preload("res://assets/sfx/mobs/abomination/abomination_hurt_3.wav"),
		]
	}
	
	match Global.GameOptions.gameplay.difficulty:
		Globals.Difficulty.HARD:
			max_hitpoints *= 1.25
			max_speed *= 1.25
			sight_radius *= 1.25
			hearing_distance *= 1.25
			awareness_timer *= 1.25
			attack_damage *= 1.25
		Globals.Difficulty.EASY:
			max_hitpoints *= .75
			max_speed *= .75
			sight_radius *= .75
			hearing_distance *= .75
			awareness_timer *= .75
			attack_damage *= .75
		_:
			pass

func _on_player_death(player : Node2D) -> void:
	if !is_alive():
		return

	target = null
	waypoints = []

	fsm.travel_to(states.idle, null)

func on_hit_by(attacker) -> void:
	.on_hit_by(attacker)

	var new_state : State
	var args
#
	if !is_alive():		
		new_state = states.die
	else:
		new_state = states.hit
		args = {
			"attacker": attacker
		}

	fsm.travel_to(new_state, args)

func play_random_sound() -> void:
	EventBus.emit_signal("play_sound_random",sounds.growl, global_position)
