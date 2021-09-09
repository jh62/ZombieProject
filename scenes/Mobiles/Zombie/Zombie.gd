extends Mobile

const States := {
	"idle": preload("res://scripts/fsm/states/zombie/ZombieIdleState.gd"),
	"walk": preload("res://scripts/fsm/states/zombie/ZombieMoveState.gd"),
	"attack": preload("res://scripts/fsm/states/zombie/ZombieAttackState.gd"),
	"die": preload("res://scripts/fsm/states/zombie/ZombieDieState.gd"),
	"headshot": preload("res://scripts/fsm/states/zombie/ZombieHeadshotState.gd"),
	"eat_wait": preload("res://scripts/fsm/states/zombie/ZombieEatWaitState.gd"),
	"eat": preload("res://scripts/fsm/states/zombie/ZombieEatState.gd"),
	"hit": preload("res://scripts/fsm/states/zombie/ZombieHitState.gd")
}

export var sight_radius := 60.0
export var hearing_distance := 300.0
export var awareness_timer := 15.0

onready var area_collision := $AreaPerception/CollisionShape2D

var target

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

	var anim_data : String
	var anim_name = fsm.current_state.get_name()

	if facing.y < 0:
		anim_data += "n"
	elif facing.y > 0:
		anim_data += "s"

	if !anim_name.begins_with("eat") && !anim_name.begins_with("die") && !anim_name.begins_with("stand"):
		if facing.x != 0:
			anim_data += "e"

	if anim_data.empty():
		anim_data = "e"

	sprite.flip_h = facing.x < 0

	var anim_p := get_anim_player()
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})
	
	if anim_p.current_animation != current_anim:
		anim_p.play(current_anim)

func _process(delta: float) -> void:
	._process(delta)
	
	if target != null && target is Mobile:
		if !target.is_alive():
			target = null

func on_hit(attacker) -> void:
	if attacker is Projectile:
		attacker = attacker as Projectile
		hitpoints -=  attacker.damage
		
	var new_state : State
	
	if !is_alive():
		new_state = States.die.new(self)
	else:
		new_state = States.hit.new(self, attacker)
		
	fsm.travel_to(new_state)

func _on_body_entered(body: Node) -> void:
	body = body as Mobile

	if !body.is_alive():
		return
		
	if target == null || target is Vector2:
		target = body
	elif global_position.distance_to(body.global_position) < global_position.distance_to(target.global_position):
		target = body

func _on_AreaHead_body_entered(body):
	var new_state = States.headshot.new(self)
	fsm.travel_to(new_state)
	
func _on_bullet_spawn(position, damage, direction = null) -> void:
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(position) > hearing_distance:
		return

	target = position

	area_collision.shape.radius = sight_radius * 2
	yield(get_tree().create_timer(awareness_timer),"timeout")
	area_collision.shape.radius = sight_radius

