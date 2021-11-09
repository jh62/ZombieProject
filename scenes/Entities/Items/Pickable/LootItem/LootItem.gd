class_name LootItem extends Pickable

const ItemPopSound := preload("res://assets/sfx/misc/item_pop.wav")


var dir_vel := Vector2(rand_range(-1.0,1.0),rand_range(-1.0,1.0)) * rand_range(40.0,60.0)
var picked := false

func _ready():
	$Sprite.frame = randi() % ($Sprite.hframes * $Sprite.vframes)

func _process(delta):
	dir_vel *= .96
	global_position = global_position.linear_interpolate(global_position + dir_vel, delta)
	if picked:
		position = position.linear_interpolate(Vector2.ZERO, delta)

func _on_Pickable_body_entered(body: Node) -> void:
	EventBus.emit_signal("on_loot_pickedup", -1)
	EventBus.emit_signal("play_sound", ItemPopSound, global_position)
	picked = true
	$Timer.start()

func _on_Timer_timeout():
	call_deferred("queue_free")
