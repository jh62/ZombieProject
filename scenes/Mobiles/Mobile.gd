class_name Mobile extends KinematicBody2D

onready var sprite := $Sprite
onready var anim_p := $AnimationPlayer

export var SPEED := 60.0

var dir := Vector2.ZERO
var facing := Vector2.ZERO
var fsm : StateMachine

func _ready() -> void:
	fsm = StateMachine.new(self)

func _process(delta: float) -> void:
	fsm.update(delta)

func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)

static func get_facing_as_string(facing : Vector2) -> String:
	var f := ""

	if facing.y > 0:
		f += "s"
	elif facing.y < 0:
		f += "n"

	if facing.x != 0:
		f += "e"

	if f.empty():
		f = "e"

	return f
