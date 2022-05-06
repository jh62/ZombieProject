extends Mobile

const MAX_KNOWS_ABOUT := 7.0

const States := {
	"idle": preload("res://scripts/fsm/states/zombie/ZombieIdleState.gd"),
	"walk": preload("res://scripts/fsm/states/zombie/ZombieMoveState2.gd"),
	"attack": preload("res://scripts/fsm/states/zombie/ZombieAttackState.gd"),
	"die": preload("res://scripts/fsm/states/zombie/ZombieDieState.gd"),
	"melee": preload("res://scripts/fsm/states/zombie/ZombieMeleeDeathState.gd"),
	"rest": preload("res://scripts/fsm/states/zombie/ZombieRestState.gd"),
	"standup": preload("res://scripts/fsm/states/zombie/ZombieStandupState.gd"),
	"headshot": preload("res://scripts/fsm/states/zombie/ZombieHeadshotState.gd"),
	"eat_wait": preload("res://scripts/fsm/states/zombie/ZombieEatWaitState.gd"),
	"eat": preload("res://scripts/fsm/states/zombie/ZombieEatState.gd"),
	"hit": preload("res://scripts/fsm/states/zombie/ZombieHitState.gd"),
}

const SOUNDS  := {
	"growl":[
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_1.wav"),
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_2.wav"),
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_3.wav")
	],
	"attack":[
		preload("res://assets/sfx/mobs/zombie/misc/firefighter_axe_hit.wav")		
	],
	"ext_hit":[
		preload("res://assets/sfx/mobs/zombie/misc/firefighter_ext_hit.wav")		
	]
}

enum Type {
	COMMON,
	POLICE,
	FIREFIGHTER
}

export var map_node : NodePath
export var state : Script
export var sight_radius := 80.0
export var hearing_distance := 300.0
export var awareness_timer := 15.0
export var attack_damage := 10
export(Type) var zombie_type := Type.COMMON

onready var area_perception := $AreaPerception
onready var area_head := $AreaHead
onready var area_soft := $SoftCollision
onready var area_attack := $AttackArea
onready var area_body := $AreaBody

onready var damage := attack_damage

var target
var map : Map
var waypoints : PoolVector2Array
var down_times := 0
var knows_about := 0.0 setget set_knows_about

func _ready() -> void:
	add_to_group(Globals.GROUP_ZOMBIE)
	EventBus.connect("on_weapon_fired", self, "_on_weapon_fired")
	EventBus.connect("on_player_death", self, "_on_player_death")

	if map_node != null:
		map = get_node(map_node)

	if state != null:
		fsm.current_state = state.new(self)
	else:
		fsm.current_state = States.idle.new(self)

	match Global.GameOptions.gameplay.difficulty:
		Globals.Difficulty.HARD:
			max_hitpoints = 46
			max_speed = 14
			sight_radius = 90
			hearing_distance = 350
			awareness_timer = 15
			attack_damage = 40
		Globals.Difficulty.EASY:
			max_hitpoints *= .75
			max_speed *= .9
			sight_radius *= .9
			hearing_distance *= .8
			awareness_timer *= .97
			attack_damage *= .92
		_:
			pass

	hitpoints = max_hitpoints
	damage = attack_damage
	area_perception.get_node("CollisionShape2D").shape.radius = sight_radius

func _on_player_death(player : Node2D) -> void:
	if !is_alive():
		return

	target = null
	waypoints = []

	var new_state

	if !(player in area_attack.get_overlapping_bodies()) || global_position.distance_to(player.global_position) > area_attack.get_node("CollisionShape2D").shape.radius:
		new_state = States.idle.new(self)
	else:
		new_state = States.eat_wait.new(self, player)

	fsm.travel_to(new_state)

func _process_animations() -> void:
	var epsilon := .25

	if dir.x < -epsilon || dir.x > epsilon:
		facing.x = dir.x
		if dir.y > -epsilon && dir.y < epsilon:
			facing.y = 0.0

	if dir.y < -epsilon || dir.y > epsilon:
		if dir.x > -epsilon && dir.x < epsilon:
			facing.x = 0.0
		facing.y = dir.y
#
	sprite.flip_h = facing.x < 0
	
	if $Particles2D.emitting:
		var p_mat : ParticlesMaterial = $Particles2D.process_material
		p_mat.direction.x = -facing.x * 10
		
func kill() -> void:
	.kill()
	var new_state = States.headshot.new(self)
	fsm.travel_to(new_state)

func on_hit_by(attacker) -> void:
	.on_hit_by(attacker)
	hitpoints -=  attacker.damage
	
	var attacker_dir = attacker.linear_velocity.normalized().dot(dir)
	
	if attacker_dir >= 0:
		$Particles2D.emitting = true
		$Particles2D.amount = max_hitpoints - hitpoints

	var new_state : State

	if !is_alive():
		if attacker is MeleeWeapon:
			new_state = States.melee.new(self, attacker.melee_type)
		else:
			down_times += 1
			new_state = States.die.new(self)
#			else:
#				new_state = States.headshot.new(self)
	else:
		new_state = States.hit.new(self, attacker)

	fsm.travel_to(new_state)


func _on_AreaBody_body_entered(body):
	if is_instance_valid(body):
		body._on_impact(self)

func _on_AreaHead_body_entered(body : Node2D):
	pass

func is_facing_target(target_pos : Vector2) -> bool:
	var dir_to_mob = global_position.direction_to(target_pos)
	var is_facing_mob = facing.dot(dir_to_mob) > 0
	return is_facing_mob

func _on_AreaPerception_body_entered(body):
	var mob = body as Mobile

	if !mob.is_alive():
		return

	knows_about = MAX_KNOWS_ABOUT

	var facing_target = is_facing_target(mob.global_position)
	var can_see_target = check_LOS(mob)

	if !(mob.aiming && can_see_target) || (facing_target && can_see_target):
		target = mob
	else:
		$TimerPerception.start()

func _on_TimerPerception_timeout():
	if target != null || area_perception.get_overlapping_bodies().empty() || knows_about == 0.0:
		$TimerPerception.stop()
		return

	var mob = area_perception.get_overlapping_bodies()[0]
	knows_about = MAX_KNOWS_ABOUT

	var facing_target = is_facing_target(mob.global_position)
	var can_see_target = check_LOS(mob)
	var distance_to_target = global_position.distance_to(mob.global_position)

	if !(mob.aiming && can_see_target) || (facing_target && can_see_target) || (can_see_target && distance_to_target < sight_radius / 4):
		target = mob

func _on_fuelcan_explode(_position):
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(_position) > hearing_distance * 2.0:
		return

	target = Global.get_area_point(_position, 80.0)

func _on_weapon_fired(_position) -> void:
	yield(get_tree().create_timer(0.5),"timeout")
	
	if !is_instance_valid(self):
		return
		
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(_position) > hearing_distance:
		return

	target = Global.get_area_point(_position, 60.0)

func play_random_sound() -> void:
	EventBus.emit_signal("play_sound_random",SOUNDS.growl, global_position)

func _on_screen_exited():
	._on_screen_exited()

	if target == null || (target is Vector2):
		return

	target = target.global_position # go to last known location

func set_can_move(_can_move) -> void:
	can_move = _can_move

func set_knows_about(_value) -> void:
	knows_about = clamp(_value, 0.0, MAX_KNOWS_ABOUT)