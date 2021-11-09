class_name FuelCan extends RigidBody2D

signal on_explode(position)

const SoundPickUp := preload("res://assets/sfx/misc/fuelcan_pickup.wav")

export var chance := 1.0
export var fuel_amount := 0.0 setget set_fuelamount

var player
var exploded := false

func _ready():
	if chance < randf():
		call_deferred("queue_free")
		return

	if !fuel_amount:
		fuel_amount = rand_range(1.5, Global.MAX_FUEL_LITERS * .33)

func _process(delta):
	if player != null:
		if player.is_alive():
			show_behind_parent = player.facing.y >= 0
			$Sprite.offset = -(player.facing * 1.7)
			global_position = player.global_position

func explode() -> void:
	if $VisibilityNotifier2D.is_on_screen():
		EventBus.emit_signal("on_fuelcan_explode", global_position)

	var explosion := preload("res://scenes/Entities/Explosion/Explosion.tscn")
	EventBus.emit_signal("on_object_spawn", explosion, global_position)
	call_deferred("queue_free")

func on_player_death() -> void:
	set_process(false)
	set_physics_process(false)
	linear_velocity = Vector2(rand_range(-10.0,10.0),10.0)

func set_fuelamount(new_amount):
	fuel_amount = max(0.0, new_amount)

func _on_Area2D_body_entered(body):
	if (body is Projectile):
		explode()
		return

	if !(body is Player):
		return

	var p = body as Player

	if p.find_node("FuelCan*",false, false):
		return

	p.connect("on_search_start", self, "on_action_pickup")

func _on_Area2D_body_exited(body):
	if !(body is Player):
		return

	var p = body as Player
	p.disconnect("on_search_start", self, "on_action_pickup")

func on_action_pickup(mob) -> void:
	var parent = get_parent()
	parent.remove_child(self)
	yield(parent.get_tree(),"idle_frame")

	player = mob
	player.connect("on_death", self, "on_player_death")
	player.add_child(self)

	$CollisionShape2D.disabled = true
	$Area2D.monitoring = false
	$Area2D.monitorable = false

	EventBus.emit_signal("play_sound", SoundPickUp, player.global_position)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.begins_with("explode"):
		queue_free()
