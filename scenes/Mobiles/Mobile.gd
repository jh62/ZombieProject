class_name Mobile extends KinematicBody2D

signal on_footstep(mob)

export var speed := 20.0
export var max_hitpoints := 10.0 

onready var sprite := $Sprite

var hitpoints := max_hitpoints setget set_hitpoints
var dir := Vector2.ZERO
var vel := Vector2.ZERO
var facing := Vector2.ZERO
var is_eaten := false
var fsm : StateMachine

# virtual methods
func on_hit(_attacker : Node2D) -> void:
	pass
func _process_animations() -> void:
	pass

# class methods
func _ready() -> void:
	fsm = StateMachine.new(self)

func is_alive() -> bool:
	return hitpoints > 0

func _process(delta: float) -> void:
	_process_animations()
	fsm.update(delta)

func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)

func get_anim_player() -> AnimationPlayer:
	return get_node("AnimationPlayer") as AnimationPlayer

func set_hitpoints(new_value) -> void:
	hitpoints = max(0, new_value)

func on_footstep_keyframe():
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
