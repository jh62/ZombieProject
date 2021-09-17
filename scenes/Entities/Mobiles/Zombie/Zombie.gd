extends Mobile

const States := {
	"idle": preload("res://scripts/fsm/states/zombie/ZombieIdleState.gd"),
	"walk": preload("res://scripts/fsm/states/zombie/ZombieMoveState.gd"),
	"attack": preload("res://scripts/fsm/states/zombie/ZombieAttackState.gd"),
	"die": preload("res://scripts/fsm/states/zombie/ZombieDieState.gd"),
	"standup": preload("res://scripts/fsm/states/zombie/ZombieStandupState.gd"),
	"headshot": preload("res://scripts/fsm/states/zombie/ZombieHeadshotState.gd"),
	"eat_wait": preload("res://scripts/fsm/states/zombie/ZombieEatWaitState.gd"),
	"eat": preload("res://scripts/fsm/states/zombie/ZombieEatState.gd"),
	"hit": preload("res://scripts/fsm/states/zombie/ZombieHitState.gd"),
}

export var sight_radius := 60.0
export var hearing_distance := 300.0
export var awareness_timer := 15.0
export var attack_damage := 3

onready var area_collision := $AreaPerception/CollisionShape2D
onready var damage := attack_damage

var target

func _ready() -> void:
#	var collision := CollisionShape2D.new()
#	collision.shape = CapsuleShape2D.new()
#	collision.shape.radius = 3.5
#	collision.shape.height = 4.5
#	collision.position = Vector2(0,2.0)
#	collision.name = "CollisionShape2D"
#	add_child(collision)
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
	print_debug("not implemented")

func _on_AreaHead_body_entered(body : Node2D):
	var new_state = States.headshot.new(self)
	fsm.travel_to(new_state)
	body.call_deferred("queue_free")
	
func _on_bullet_spawn(position, damage, direction = null) -> void:
	if target != null && !(target is Vector2):
		return

	if global_position.distance_to(position) > hearing_distance:
		return

	target = position

	area_collision.shape.radius = sight_radius * 2
	yield(get_tree().create_timer(awareness_timer),"timeout")
	area_collision.shape.radius = sight_radius

func _on_AreaPerception_body_entered(body):
	body = body as Mobile

	if !body.is_alive():
		return
		
	if target == null || target is Vector2:
		target = body
	elif global_position.distance_to(body.global_position) < global_position.distance_to(target.global_position):
		target = body
