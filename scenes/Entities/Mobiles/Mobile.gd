class_name Mobile extends KinematicBody2D

signal on_footstep(mob)

const Blood := preload("res://scenes/Entities/FX/Blood/Blood.tscn")

export var max_speed := 20.0
export var max_hitpoints := 10.0

onready var sprite := $Sprite
onready var n_Visibility := $VisibilityNotifier2D
onready var n_RayCast := $RayCast2D

onready var hitpoints := max_hitpoints setget set_hitpoints
onready var speed := max_speed
var dir := Vector2.ZERO
var vel := Vector2.ZERO
var facing := Vector2(1,0)
var is_eaten := false
var fsm : StateMachine
var _visible_viewport := true
var can_move := true setget set_can_move

# virtual methods
func kill() -> void:
	hitpoints = 0

func on_hit_by(_attacker : Node2D) -> void:
	var angle := PI * rand_range(0.0, 2.0)
	var radius := 10.0

	if Global.GameOptions.graphics.render_blood:
		EventBus.emit_signal("on_object_spawn", Blood, global_position + Vector2(cos(angle),sin(angle)) * radius, -1)

func _process_animations() -> void:
	pass

# class methods
func _ready() -> void:
	add_to_group(Global.GROUP_MOBILE)
	fsm = StateMachine.new(self)

func is_alive() -> bool:
	return hitpoints > 0

func _process(delta: float) -> void:
	if is_visible_in_viewport():
		_process_animations()
	fsm.update(delta)

func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)

func get_anim_player() -> AnimationPlayer:
	return get_node("AnimationPlayer") as AnimationPlayer

func set_hitpoints(new_value) -> void:
	hitpoints = max(0, new_value)

func on_footstep_keyframe():
	if !is_visible_in_viewport():
		return
	emit_signal("on_footstep", self)

static func get_facing_as_string(_facing : Vector2) -> String:
	var f := ""

	if _facing.y > 0:
		f += "s"
	elif _facing.y < 0:
		f += "n"

	if _facing.x != 0:
		f += "e"

	if f.empty():
		f = "e"

	return f

func is_visible_in_viewport() -> bool:
	return n_Visibility.is_on_screen()

func set_can_move(_can_move) -> void:
	can_move = _can_move

func _on_VisibilityNotifier2D_screen_exited():
	pass # Replace with function body.

func _on_screen_exited():
	pass

func check_LOS(target) -> bool:
	n_RayCast.enabled = true
	n_RayCast.cast_to = target.global_position - position
	n_RayCast.force_raycast_update()

	var colliding = n_RayCast.is_colliding() && n_RayCast.get_collider() == target
	n_RayCast.enabled = false

	return colliding
