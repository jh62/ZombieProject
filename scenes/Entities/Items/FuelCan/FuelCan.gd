class_name FuelCan extends RigidBody2D

const SOUNDS := {
	"explode":[
		preload("res://assets/sfx/impact/fuelcan_explode.wav")
	],
	"pickup":[
		preload("res://assets/sfx/misc/fuelcan_pickup.wav")
	]
}

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
	if exploded:
		return

	exploded = true
	EventBus.emit_signal("play_sound_random_full", SOUNDS.explode, global_position, rand_range(.9,1.1), 1.0, 500.0)

	$Sprite.offset.y = -16
	$AnimationPlayer.play("explode")
	$Area2D/CollisionShape2D.shape.radius = 50.0
	yield(get_tree().create_timer(.05),"timeout")
	for b in $Area2D.get_overlapping_bodies():
		if b.has_method("kill"):
			b.vel = global_position.direction_to(b.global_position) * 10.0
			b.kill()
		elif b.has_method("explode"):
			b.explode()

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

	EventBus.emit_signal("play_sound_random", SOUNDS.pickup, player.global_position)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.begins_with("explode"):
		queue_free()
