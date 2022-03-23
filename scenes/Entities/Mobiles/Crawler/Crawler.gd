extends Mobile

const States := {
	"idle": preload("res://scripts/fsm/states/crawler/CrawlerIdleState.gd"),
	"walk": preload("res://scripts/fsm/states/crawler/CrawlerMoveState.gd"),
	"attack": preload("res://scripts/fsm/states/crawler/CrawlerAttackState.gd"),
	"die": preload("res://scripts/fsm/states/crawler/CrawlerDieState.gd"),
	"melee": preload("res://scripts/fsm/states/crawler/CrawlerMeleeDeathState.gd"),
	"hit": preload("res://scripts/fsm/states/crawler/CrawlerHitState.gd"),
}

const Sounds  := {
	"growl":[
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_1.wav"),
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_2.wav"),
		preload("res://assets/sfx/mobs/zombie/misc/zombie_growl_3.wav")
	]
}

export var Nav2D : NodePath
export var AI : Script
export var sight_radius := 90.0
export var hearing_distance := 310.0
export var awareness_timer := 15.0
export var attack_damage := 10.0

onready var area_perception := $AreaPerception
onready var area_collision := $AreaPerception/CollisionShape2D
onready var damage := attack_damage

var target
var nav : Navigation2D
var waypoints : PoolVector2Array
var down_times := 0
var fleeing := false
var threat : Node2D

func _ready() -> void:
	add_to_group(Globals.GROUP_ZOMBIE)
	EventBus.connect("on_bullet_spawn", self, "_on_bullet_spawn")
	EventBus.connect("on_player_death", self, "_on_player_death")

	if !Nav2D.is_empty():
		nav = get_node(Nav2D).get_node("TileMap/Navigation2D")

	if AI != null:
		fsm.current_state = AI.new(self)
	else:
		fsm.current_state = States.idle.new(self)
	area_collision.shape.radius = sight_radius

	match Global.GameOptions.gameplay.difficulty:
		Globals.Difficulty.HARD:
			max_hitpoints = 4.0
			max_speed = 32.0
			sight_radius = 110.0
			hearing_distance = 380.0
			awareness_timer = 18.0
			attack_damage = 10.0
			hitpoints = max_hitpoints
		Globals.Difficulty.NORMAL:
			max_hitpoints = 3
			max_speed = 28.0
			sight_radius = 97.0
			hearing_distance = 340
			awareness_timer = 16.0
			attack_damage = 10.0
		_:
			pass

func _on_player_death(player : Node2D) -> void:
	yield(get_tree(),"idle_frame")
	var p_pos := player.global_position
	waypoints = []


	var new_state = States.idle.new(self)
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

func kill() -> void:
	var new_state = States.die.new(self)
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
	kill()
	body.call_deferred("queue_free")

func _on_fuelcan_explode(_position):
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(_position) > hearing_distance * 2.0:
		return

	var target_pos = get_area_point(_position, 80.0)
	target = nav.get_closest_point(target_pos)

func _on_bullet_spawn(_position, _damage, _direction = null, aimed := false) -> void:
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(_position) > hearing_distance:
		return

	var target_pos = get_area_point(_position)
	target = nav.get_closest_point(target_pos)

func get_area_point(_position, _radius := 50.0) -> Vector2:
	var angle := rand_range(0.0, 2.0) * PI
	var dir := Vector2(sin(angle),cos(angle))
	var radius := _radius
	var target_pos = _position + dir * radius

	return target_pos

func _on_AreaPerception_body_entered(body):
	var mob = body as Mobile

	if !mob.is_alive():
		return

	if fleeing:
		return

	if target != null && (target is Mobile):
		var dist_to_mob := global_position.distance_to(mob.global_position)
		var dist_to_target := global_position.distance_to(target.global_position)

		if dist_to_mob > dist_to_target:
			return

	target = mob

func play_random_sound() -> void:
	EventBus.emit_signal("play_sound_random",Sounds.growl, global_position)

func _on_screen_exited():
	._on_screen_exited()

	fleeing = false

	if target == null || (target is Vector2):
		return

	target = target.global_position # go to last known location

func set_can_move(_can_move) -> void:
	can_move = _can_move
