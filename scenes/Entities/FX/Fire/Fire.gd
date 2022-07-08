extends Node2D

onready var sprite := $AnimatedSprite

export var max_damage := 1.0
export var lifetime := 5.0

onready var _mob = get_parent()

#var burning := false
var damage
var elapsed := 0.0

func _ready():
	pass

func _process(delta):
	elapsed += delta
	
	var life_percentage := elapsed / lifetime
	
	if life_percentage >= 1.1:
		call_deferred("queue_free")
		return
		
	$AudioStreamPlayer2D.volume_db = -24 * life_percentage
	
	if life_percentage <= 1.0:
		damage = max_damage - max_damage * life_percentage
		sprite.scale.x = 1.0 - life_percentage
		sprite.scale.y = 1.0 - life_percentage

func _on_Timer_timeout():
	if _mob == null || !_mob.is_alive():
		$Timer.stop()
		call_deferred("queue_free")
		return

	if !_mob.fsm.current_state.get_name().begins_with("hit"):
		_mob.on_hit_by(self)
		
		if _mob.is_in_group(Global.GROUP_HOSTILES):
			var sprite = _mob.get_node("Sprite")
			sprite.self_modulate = sprite.self_modulate.darkened(damage / _mob.max_hitpoints)
