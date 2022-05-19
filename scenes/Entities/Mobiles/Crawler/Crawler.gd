extends Mobile

const MAX_KNOWS_ABOUT := 12.0

const States := {
	"idle": preload("res://scripts/fsm/states/crawler/CrawlerIdleState.gd"),
	"walk": preload("res://scripts/fsm/states/crawler/CrawlerMoveState2.gd"),
	"flee": preload("res://scripts/fsm/states/crawler/CrawlerFleeState.gd"),
	"attack": preload("res://scripts/fsm/states/crawler/CrawlerAttackState.gd"),
	"die": preload("res://scripts/fsm/states/crawler/CrawlerDieState.gd"),
	"melee": preload("res://scripts/fsm/states/crawler/CrawlerMeleeDeathState.gd"),
	"hit": preload("res://scripts/fsm/states/crawler/CrawlerHitState.gd"),
}

const Sounds  := {
	"growl":[
		preload("res://assets/sfx/mobs/crawler/misc/crawler_farcry.wav")
	]
}

export var map_node : NodePath
export var state : Script
export var sight_radius := 80.0
export var hearing_distance := 300.0
export var awareness_timer := 15.0
export var attack_damage := 3

onready var area_perception := $AreaPerception
onready var area_head := $AreaHead
onready var area_soft := $SoftCollision
onready var area_attack := $AttackArea
onready var area_body := $AreaBody

onready var damage := attack_damage

var target
var map : Map
var waypoints : PoolVector2Array
var knows_about := 0.0

func _ready() -> void:
	add_to_group(Globals.GROUP_ZOMBIE)
	add_to_group(Globals.GROUP_SPECIAL)

	EventBus.connect("on_weapon_fired", self, "_on_weapon_fired")
	EventBus.connect("on_player_death", self, "_on_player_death")
	
	if !map_node.is_empty():
		map = get_node(map_node)

	if state != null:
		fsm.current_state = state.new(self)
	else:
		fsm.current_state = States.idle.new(self)

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

	hitpoints = max_hitpoints
	damage = attack_damage
	area_perception.get_node("CollisionShape2D").shape.radius = sight_radius

func _on_player_death(player : Node2D) -> void:
	if !is_alive():
		return

	target = Vector2.ZERO # change to something more meaningful
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

	var new_state = States.die.new(self)
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

	target = Global.get_area_point(_position, 40.0)

func _on_AreaPerception_body_entered(body):
	var mob = body as Mobile

	if !mob.is_alive():
		return

	if fsm.current_state is CrawlerFleeState:
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

func _on_AreaBody_body_entered(body):
	if !is_alive():
		return
		
	if is_instance_valid(body):
		body._on_impact(self)

func search_nearby() -> void:
	if !is_alive():
		return
		
	if area_perception.get_overlapping_bodies().size() == 0:
		return
	
	var mob = area_perception.get_overlapping_bodies()[0]
	target = mob
	knows_about = MAX_KNOWS_ABOUT
