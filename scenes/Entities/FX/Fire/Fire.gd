extends Node2D

onready var sprite := $AnimatedSprite
onready var light := $Light2D

export var damage := 9.7
export var lifetime := 5.0

onready var p_zombie = get_parent()

var burning := false
var elapsed := 0.0

func _ready():
	pass

func _process(delta):
	elapsed += delta
	$AudioStreamPlayer2D.volume_db -= elapsed * 3.0

	if elapsed >= lifetime:
		sprite.scale.y -= 0.025
		if sprite.scale.y <= 0.0:
			call_deferred("queue_free")

func _on_Timer_timeout():
	if p_zombie == null || !p_zombie.is_alive():
		$Timer.stop()
		return

	if !p_zombie.fsm.current_state.get_name().begins_with("hit"):
		p_zombie.on_hit_by(self)
		var sprite = p_zombie.get_node("Sprite")
		sprite.self_modulate = sprite.self_modulate.darkened(damage / p_zombie.max_hitpoints)
