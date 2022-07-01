class_name Pickable extends RigidBody2D

export var pick_delay := 0.45
export var overlay_text := ""

onready var n_Sprite := $Sprite
onready var n_AreaCollision := $Area2D/CollisionShape2D
onready var n_CanvasLabel := $CanvasLayer/Label
onready var n_CanvasAnimationPlayer := $CanvasLayer/AnimationPlayer

func _ready():
	linear_velocity = Vector2(rand_range(-1.0,1.0),rand_range(-1.0,1.0)) * 1000.0
	yield(get_tree().create_timer(pick_delay),"timeout")
	n_AreaCollision.disabled = false

func _process(delta):
	if sleeping:
		return

	if linear_velocity == Vector2.ZERO:
		sleeping = true

func _unhandled_input(event):
	if event.is_action_pressed("action_alt"):
		for body in $Area2D.get_overlapping_bodies():
			on_picked_up_by(body)
			return

func _on_Area2D_body_entered(body):
	on_picked_up_by(body)

func get_picked_sound() ->  AudioStream:
	return preload("res://assets/sfx/misc/item_pop.wav")

func show_overlay_text(text : String, position : Vector2) -> void:
	n_CanvasLabel.text = text
	n_CanvasLabel.rect_global_position = position
	n_CanvasAnimationPlayer.play("show_label")

# virtual methods
func on_picked_up_by(body) -> void:
	visible = false
	EventBus.emit_signal("play_sound", get_picked_sound(), global_position)
	
	if !overlay_text.empty():
		show_overlay_text(overlay_text, body.global_position)
		yield(n_CanvasAnimationPlayer,"animation_finished")
		
	call_deferred("queue_free")

func _on_Area2D_body_exited(body):
	EventBus.emit_signal("on_tooltip", "")
