class_name BaseZombie extends Mobile

var MAX_KNOWS_ABOUT := 7.0

var states := {}
var sounds  := {}

export var map_node : NodePath
export var state : Script
export var sight_radius := 80.0
export var hearing_distance := 300.0
export var awareness_timer := 15.0
export var attack_damage := 3
export(Globals.ZombieType) var zombie_type := Globals.ZombieType.COMMON

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
var last_hit := 0

func _ready() -> void:
	add_to_group(Globals.GROUP_HOSTILES)
	EventBus.connect("on_weapon_fired", self, "_on_weapon_fired")
	EventBus.connect("on_player_death", self, "_on_player_death")

	call_deferred("initialize")

func initialize() -> void:
	if !map_node.is_empty():
		map = get_node(map_node)
		
	var new_state
	
	if state != null:
		new_state = state.new(self)
	elif states.has("idle"):
		new_state = states.idle
	
	if new_state != null:
		fsm.travel_to(new_state, null)
		
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
	pass

func _process_animations() -> void:
	._process_animations()
	
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
	fsm.travel_to(states.die, null)

func on_hit_by(attacker) -> void:
	.on_hit_by(attacker)
	hitpoints -=  attacker.damage

func _on_AreaBody_body_entered(body):
	if !is_alive():
		return
		
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
	
	if (facing_target && can_see_target) || (can_see_target && !mob.aiming && !PlayerStatus.has_perk(Perk.PERK_TYPE.SHADOW_DANCER)):
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
	
	if (facing_target && can_see_target) || (can_see_target && !mob.aiming && !PlayerStatus.has_perk(Perk.PERK_TYPE.SHADOW_DANCER)) || (can_see_target && distance_to_target < sight_radius / 4):
		target = mob

#	if !(mob.aiming && can_see_target) || (facing_target && can_see_target) || (can_see_target && distance_to_target < sight_radius / 4):
#		target = mob

func _on_fuelcan_explode(_position):
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(_position) > hearing_distance * 2.0:
		return

	target = Global.get_area_point(_position, sight_radius)

func _on_weapon_fired(_position) -> void:
	yield(get_tree().create_timer(0.5),"timeout")
	
	if !is_instance_valid(self):
		return
		
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(_position) > hearing_distance:
		return

	target = Global.get_area_point(_position, sight_radius)

func play_random_sound() -> void:
	pass

func _on_screen_exited():
	if target == null || (target is Vector2):
		return

	target = target.global_position # go to last known location
	
	if target == null || (target is Vector2):
		return

func set_knows_about(_value) -> void:
	knows_about = clamp(_value, 0.0, MAX_KNOWS_ABOUT)
	
func search_nearby() -> void:
	if !is_alive():
		return
		
	if area_perception.get_overlapping_bodies().size() == 0:
		return
	
	var mob = area_perception.get_overlapping_bodies()[0]
	target = mob
	knows_about = MAX_KNOWS_ABOUT

func on_footstep_keyframe():
	if !is_visible_in_viewport():
		return
		
	map._on_mob_footstep(self)

func set_can_move(_can_move) -> void:
	can_move = _can_move
