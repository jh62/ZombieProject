extends Node2D

onready var sprite := $AnimatedSprite
onready var light := $Light2D

export var damage := 9.7
export var lifetime := 5.0

var elapsed := 0.0

func _ready():
	yield(get_tree().create_timer(.1),"timeout")
	sprite.playing = true
	$Timer.start()

func _process(delta):
	elapsed += delta
	$AudioStreamPlayer2D.volume_db -= elapsed * 3.0

	if elapsed >= lifetime:
		sprite.scale.y -= 0.025
		if sprite.scale.y <= 0.0:
			call_deferred("queue_free")

func _on_Timer_timeout():
	return
	var z := get_parent()

	if z == null || !z.is_alive():
		$Timer.stop()
		return

	if !z.fsm.current_state.get_name().begins_with("hit"):
		z.on_hit_by(self)
		var sprite := z.get_node("Sprite")
		sprite.self_modulate = sprite.self_modulate.darkened(.25)
