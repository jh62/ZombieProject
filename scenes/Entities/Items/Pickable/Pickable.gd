class_name Pickable extends Area2D

const ItemPopSound := preload("res://assets/sfx/misc/item_pop.wav")

export var pick_delay := 1.15

var dir_vel := Vector2(rand_range(-1.0,1.0),rand_range(-1.0,1.0)) * rand_range(40.0,60.0)
var picked := false

# virtual methods
func on_picked_up_by(body) -> void:
	pass

func _ready():
	$CollisionShape2D.disabled = true
	yield(get_tree().create_timer(pick_delay),"timeout")
	$CollisionShape2D.disabled = false

func _process(delta):
	dir_vel *= .96
	global_position = global_position.linear_interpolate(global_position + dir_vel, delta)

func _on_Pickable_body_entered(body: Node) -> void:
	on_picked_up_by(body)
	EventBus.emit_signal("play_sound", ItemPopSound, global_position)
	picked = true
	$Timer.start()

func _on_Timer_timeout():
	call_deferred("queue_free")
