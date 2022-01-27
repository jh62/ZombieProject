class_name Pickable extends RigidBody2D

export var pick_delay := .45

onready var area_shape := $Area2D/CollisionShape2D
onready var label := $CanvasLayer/RichTextLabel
onready var tween := $Tween

var _flash_bounce := false
var _flash_delay := 4.0
var _flash_secs := 0.1

func _ready():
	linear_velocity = Vector2(rand_range(-1.0,1.0),rand_range(-1.0,1.0)) * rand_range(40.0,60.0)
	yield(get_tree().create_timer(pick_delay),"timeout")
	area_shape.disabled = false
	tween.interpolate_property($Sprite.material,"shader_param/hit_strength", 0.0, 1.0, _flash_secs, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, _flash_delay)
	tween.start()


func _unhandled_input(event):
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

func _on_Tween_tween_completed(object, key):
	_flash_bounce = !_flash_bounce
	var old_val = 0.5 if _flash_bounce else 0.0
	var new_val = 0.0 if _flash_bounce else 0.5
	var delay = 0.0 if _flash_bounce else _flash_delay

	tween.interpolate_property($Sprite.material,"shader_param/hit_strength", old_val, new_val, _flash_secs, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
	tween.start()
