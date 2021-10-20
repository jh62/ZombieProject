extends Mobile

const States := {
	"idle": preload("res://scripts/fsm/states/zombie/ZombieIdleState.gd"),
	"walk": preload("res://scripts/fsm/states/zombie/ZombieMoveState.gd"),
	"attack": preload("res://scripts/fsm/states/zombie/ZombieAttackState.gd"),
	"die": preload("res://scripts/fsm/states/zombie/ZombieDieState.gd"),
	"rest": preload("res://scripts/fsm/states/zombie/ZombieRestState.gd"),
	"standup": preload("res://scripts/fsm/states/zombie/ZombieStandupState.gd"),
	"headshot": preload("res://scripts/fsm/states/zombie/ZombieHeadshotState.gd"),
	"melee": preload("res://scripts/fsm/states/zombie/ZombieBashedState.gd"),
	"eat_wait": preload("res://scripts/fsm/states/zombie/ZombieEatWaitState.gd"),
	"eat": preload("res://scripts/fsm/states/zombie/ZombieEatState.gd"),
	"hit": preload("res://scripts/fsm/states/zombie/ZombieHitState.gd"),
}

const Sounds  := [
	preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_1.wav"),
	preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_2.wav"),
	preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_3.wav"),
]

export var sight_radius := 60.0
export var hearing_distance := 300.0
export var awareness_timer := 15.0
export var attack_damage := 3

onready var area_perception := $AreaPerception
onready var area_collision := $AreaPerception/CollisionShape2D
onready var damage := attack_damage

var target
var nav : Navigation2D
var waypoints : PoolVector2Array

func _ready() -> void:
	add_to_group(Globals.GROUP_ZOMBIE)
	EventBus.connect("on_bullet_spawn", self, "_on_bullet_spawn")
	fsm.current_state = States.idle.new(self)
	area_collision.shape.radius = sight_radius

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

func _process(delta: float) -> void:
	._process(delta)

#	if target != null:
#		if target is Mobile && !target.is_alive():
#			target = null

func on_hit_by(attacker) -> void:
	hitpoints -=  attacker.damage

	var new_state : State

	if !is_alive():
		if attacker is MeleeWeapon:
			new_state = States.melee.new(self)
		else:
			new_state = States.die.new(self)
	else:
		new_state = States.hit.new(self, attacker)

	fsm.travel_to(new_state)

func _on_AreaHead_body_entered(body : Node2D):
	var new_state = States.headshot.new(self)
	fsm.travel_to(new_state)
	body.call_deferred("queue_free")

func _on_bullet_spawn(position, damage, direction = null) -> void:
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(position) > hearing_distance:
		return

	var angle := rand_range(0.0, 2.0) * PI
	var dir := Vector2(sin(angle),cos(angle))
	var radius := 50.0
	var target_pos = position + dir * radius

	target = nav.get_closest_point(target_pos)

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

func play_random_sound() -> void:
	EventBus.emit_signal("play_sound_random",Sounds, global_position)

func _on_screen_exited():
	._on_screen_exited()

	if target == null || (target is Vector2):
		return

	target = target.global_position # go to last known location
