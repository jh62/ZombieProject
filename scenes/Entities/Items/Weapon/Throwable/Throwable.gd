class_name Throwable extends BaseWeapon

#var speed : float = 200
#var end_position : Vector2 = Vector2(0,0) setget set_end_position
#var start_position : Vector2
#var active : bool = false
#var dir : Vector2 = Vector2(0, 0)
#var total_length : float
#var shadow_scale
#
#func _ready():
#	shadow_scale = $Shadow.scale
#	add_to_group("grenades")
#	pass
#
#func _physics_process(delta):
#	if active:
#		var x1 = start_position.x
#		var x3 = end_position.x
#		var x = global_position.x
#		var x2 = (x1+x3)/2
#		global_position += speed*delta*dir
#		$Sprite.global_position.y = ((-50+start_position.y)*(x-x2)*(x-x3)/((x1-x2)*(x1-x3))
#						+ (min(-50+start_position.y , end_position.y)-50)*(x-x1)*(x-x3)/((x2-x1)*(x2-x3))+
#						end_position.y*(x-x1)*(x-x2)/((x3-x1)*(x3-x2)))
#
#		if (global_position - end_position).length() < 1:
#			explode()
#			active = false
#
#func explode():
#	$Shadow.visible = false
#	$Sprite.visible = false
#	for b in get_overlapping_bodies():
#		if b.is_in_group("enemies"):
#			b.on_hit(self)
#	$Explosion.playing = true
#	$Explosion.visible = true
#	$AudioStreamPlayer.play()
#
#
#func set_end_position(p : Vector2):
#	end_position = p
#	start_position = global_position
#	dir = (end_position - global_position).normalized()
#	total_length = (end_position - start_position).length()
#	speed = total_length
#	active = true
#
#
#func _on_Explosion_animation_finished():
#	queue_free()
