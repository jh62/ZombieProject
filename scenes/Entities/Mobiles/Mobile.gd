class_name Mobile extends KinematicBody2D

signal on_footstep(mob)

export var max_speed := 20.0
export var max_hitpoints := 10.0

onready var sprite := $Sprite

onready var hitpoints := max_hitpoints setget set_hitpoints
onready var speed := max_speed
var dir := Vector2.ZERO
var vel := Vector2.ZERO
var facing := Vector2.ZERO
var is_eaten := false
var fsm : StateMachine
var _visible_viewport := true

# virtual methods
func on_hit_by(_attacker : Node2D) -> void:
	pass
func _process_animations() -> void:
	pass

# class methods
func _ready() -> void:
	fsm = StateMachine.new(self)

func is_alive() -> bool:
	return hitpoints > 0

func _process(delta: float) -> void:
	if _visible_viewport:
		_process_animations()
	fsm.update(delta)

func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)

func get_anim_player() -> AnimationPlayer:
	return get_node("AnimationPlayer") as AnimationPlayer

func set_hitpoints(new_value) -> void:
	hitpoints = max(0, new_value)

func on_footstep_keyframe():
	if _visible_viewport:
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

func _on_screen_entered():
	_visible_viewport = true

func _on_screen_exited():
	_visible_viewport = false
