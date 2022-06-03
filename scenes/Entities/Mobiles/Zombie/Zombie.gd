class_name Zombie extends BaseZombie

func _ready() -> void:
	add_to_group(Globals.GROUP_ZOMBIE)
	
	states = {
		"idle": preload("res://scripts/fsm/states/zombie/ZombieIdleState.gd").new(self),
		"walk": preload("res://scripts/fsm/states/zombie/ZombieMoveState.gd").new(self),
		"attack": preload("res://scripts/fsm/states/zombie/ZombieAttackState.gd").new(self),
		"die": preload("res://scripts/fsm/states/zombie/ZombieDieState.gd").new(self),
		"rest": preload("res://scripts/fsm/states/zombie/ZombieRestState.gd").new(self),
		"standup": preload("res://scripts/fsm/states/zombie/ZombieStandupState.gd").new(self),
		"eat_wait": preload("res://scripts/fsm/states/zombie/ZombieEatWaitState.gd").new(self),
		"eat": preload("res://scripts/fsm/states/zombie/ZombieEatState.gd").new(self),
		"hit": preload("res://scripts/fsm/states/zombie/ZombieHitState.gd").new(self),
	}

	sounds  = {
	"growl":[
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_1.wav"),
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_2.wav"),
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_3.wav")
	],
	"attack":[
		preload("res://assets/sfx/mobs/zombie/attack/zombie_growl_attack_1.wav"),
		preload("res://assets/sfx/mobs/zombie/attack/zombie_growl_attack_2.wav"),
		preload("res://assets/sfx/mobs/zombie/attack/zombie_growl_attack_3.wav"),
	],
	"eating":[
		preload("res://assets/sfx/mobs/zombie/eat/zombie_eating_1.wav")
	]
}	

func _on_player_death(player : Node2D) -> void:
	if !is_alive():
		return

	target = null
	waypoints = []

	var new_state
	var args

	if !(player in area_attack.get_overlapping_bodies()): #|| global_position.distance_to(player.global_position) > area_attack.get_node("CollisionShape2D").shape.radius:
		new_state = states.idle
	else:
		new_state = states.eat_wait
		args = {
			"corpse": player
		}

	yield(get_tree(),"idle_frame")
	fsm.travel_to(new_state, args)

func on_hit_by(attacker) -> void:
	.on_hit_by(attacker)

	var new_state : State

	if !is_alive():
		if attacker is MeleeWeapon:
			fsm.travel_to(states.die, {
				"melee_type": attacker.melee_type
			})
		else:
			fsm.travel_to(states.die, null)
	else:
		fsm.travel_to(states.hit, {
			"attacker": attacker
		})

func on_headshot() -> void:
	hitpoints = 0
	fsm.travel_to(states.die, {
		"headshot": true
	})
	
func _on_AreaHead_body_entered(body : Node2D):
	pass

func play_random_sound() -> void:
	EventBus.emit_signal("play_sound_random",sounds.growl, global_position)

