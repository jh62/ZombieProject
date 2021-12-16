class_name Pickable extends RigidBody2D

export var pick_delay := .45

onready var area_shape := $Area2D/CollisionShape2D
onready var label := $CanvasLayer/RichTextLabel

var dir_vel := Vector2(rand_range(-1.0,1.0),rand_range(-1.0,1.0)) * rand_range(40.0,60.0)

func _ready():
	linear_velocity = dir_vel
	yield(get_tree().create_timer(pick_delay),"timeout")
	area_shape.disabled = false

#func _process(delta):
#	if label.visible:
#		label.rect_position = global_position

func _unhandled_key_input(event):
	if event.is_action_pressed("action_alt"):
		for body in $Area2D.get_overlapping_bodies():
			on_picked_up_by(body)
			return

func _on_Area2D_body_entered(body):
	on_picked_up_by(body)

func get_picked_sound() ->  AudioStream:
	return preload("res://assets/sfx/misc/item_pop.wav")

# virtual methods
func on_picked_up_by(body) -> void:
	EventBus.emit_signal("play_sound", get_picked_sound(), global_position)
	call_deferred("queue_free")

func _on_Area2D_body_exited(body):
	$CanvasLayer/RichTextLabel.visible = false
