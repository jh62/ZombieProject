class_name Pickable extends RigidBody2D

export var pick_delay := 1.15

var dir_vel := Vector2(rand_range(-1.0,1.0),rand_range(-1.0,1.0)) * rand_range(40.0,60.0)

func _ready():
	linear_velocity = dir_vel
	$CollisionShape2D.disabled = true
	yield(get_tree().create_timer(pick_delay),"timeout")
	$CollisionShape2D.disabled = false

func _unhandled_key_input(event):
	if event.is_action_pressed("action_alt"):
		for body in $Area2D.get_overlapping_bodies():
			on_picked_up_by(body)
			return

func _on_Area2D_body_entered(body):
	if Globals.GameOptions.gameplay.auto_pickup:
		on_picked_up_by(body)
	else:
		$CanvasLayer/RichTextLabel.visible = true
		$CanvasLayer/RichTextLabel.append_bbcode("[center]Press [color=#fffc00]{0}[/color] to pick up[/center]".format({0:InputMap.get_action_list("action_alt")[0].as_text()}))

func get_picked_sound() ->  AudioStream:
	return preload("res://assets/sfx/misc/item_pop.wav")

# virtual methods
func on_picked_up_by(body) -> void:
	EventBus.emit_signal("play_sound", get_picked_sound(), global_position)
	call_deferred("queue_free")

func _on_Area2D_body_exited(body):
	$CanvasLayer/RichTextLabel.visible = false
