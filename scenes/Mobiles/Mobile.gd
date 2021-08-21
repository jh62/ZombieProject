class_name Mobile extends KinematicBody2D

onready var sprite := $Sprite
onready var anim_p := $AnimationPlayer

export var SPEED := 60.0
export var hitpoints := 10.0 setget set_hitpoints

var dir := Vector2.ZERO
var facing := Vector2.ZERO
var fsm : StateMachine

# virtual methods
func on_hit(attacker : Node2D) -> void:
	pass

func _ready() -> void:
	fsm = StateMachine.new(self)

func is_alive() -> bool:
	return hitpoints > 0

func _process(delta: float) -> void:
	fsm.update(delta)

func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)

func set_hitpoints(new_value) -> void:
	hitpoints = max(0, new_value)

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
