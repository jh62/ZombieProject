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

const Sounds  := {
	"growl":[
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_1.wav"),
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_2.wav"),
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_3.wav")
	]
}

export var state : Script
export var sight_radius := 80.0
export var hearing_distance := 300.0
export var awareness_timer := 15.0
export var attack_damage := 3

onready var area_perception := $AreaPerception
onready var area_head := $AreaHead
onready var area_soft := $SoftCollision
onready var area_attack := $AttackArea

onready var damage := attack_damage

var target
var map : Map
var waypoints : PoolVector2Array
var down_times := 0
var knows_about := 0.0

func _ready() -> void:
	add_to_group(Globals.GROUP_ZOMBIE)
	EventBus.connect("on_weapon_fired", self, "_on_weapon_fired")
	EventBus.connect("on_player_death", self, "_on_player_death")

	if state != null:
		fsm.current_state = state.new(self)
	else:
		fsm.current_state = States.idle.new(self)

	match Global.GameOptions.gameplay.difficulty:
		Globals.Difficulty.HARD:
			max_hitpoints = 40
			max_speed = 10
			sight_radius = 90
			hearing_distance = 350
			awareness_timer = 15
			attack_damage = 4
		Globals.Difficulty.NORMAL:
			max_hitpoints = 20
			max_speed = 8
			sight_radius = 90
			hearing_distance = 325
			awareness_timer = 15
			attack_damage = 3.25
		_:
			pass

	hitpoints = max_hitpoints
	damage = attack_damage
	area_perception.get_node("CollisionShape2D").shape.radius = sight_radius

func _on_player_death(player : Node2D) -> void:
	if !is_alive():
		return

#	if area_attack.get_overlapping_bodies().size() == 0:
#		target = Vector2.ZERO # change to something more meaningful
#		var new_state = States.idle.new(self)
#		fsm.travel_to(new_state)
#		return
#
#	target = null
#	waypoints = []
#
#	var new_state = States.eat_wait.new(self, player)
#	fsm.travel_to(new_state)

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

func kill() -> void:
	.kill()
	var new_state = States.headshot.new(self)
	fsm.travel_to(new_state)

func on_hit_by(attacker) -> void:
	.on_hit_by(attacker)
	hitpoints -=  attacker.damage

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

func _on_AreaHead_body_entered(body : Node2D):
	pass

func _on_fuelcan_explode(_position):
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(_position) > hearing_distance * 2.0:
		return

	target = Global.get_area_point(_position, 80.0)

func _on_weapon_fired(_position) -> void:
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(_position) > hearing_distance:
		return

	target = Global.get_area_point(_position, 60.0)

func _on_AreaPerception_body_entered(body):
	var mob = body as Mobile

	if !mob.is_alive():
		return

	if target != null && (target is Mobile):
		var dist_to_mob := global_position.distance_to(mob.global_position)
		var dist_to_target := global_position.distance_to(target.global_position)

		if dist_to_mob > dist_to_target:
			return

	target = mob
	knows_about = MAX_KNOWS_ABOUT

func play_random_sound() -> void:
	EventBus.emit_signal("play_sound_random",Sounds.growl, global_position)

func _on_screen_exited():
	._on_screen_exited()

	if target == null || (target is Vector2):
		return

	target = target.global_position # go to last known location

func set_can_move(_can_move) -> void:
	can_move = _can_move
