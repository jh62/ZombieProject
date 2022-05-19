class_name FuelCan extends RigidBody2D

signal on_explode(position)

const SoundPickUp := preload("res://assets/sfx/misc/fuelcan_pickup.wav")
const SoundFlow := preload("res://assets/sfx/misc/fuelcan_flow.wav")
const SoundFlowStop := preload("res://assets/sfx/misc/fuelcan_end.wav")

export var fuel_amount := 0.0 setget set_fuelamount
export var can_pickup := true

var player
var exploded := false

func _ready():
	add_to_group(Global.GROUP_FUELCAN)
	if !fuel_amount:
		fuel_amount = rand_range(1.5, Global.MAX_FUEL_LITERS * .25)

func _process(delta):
	if player != null:
		if player.is_alive():
			show_behind_parent = player.facing.y >= 0
			$Sprite.offset = -(player.facing * 1.7)
			global_position = player.global_position

func explode() -> void:
	if exploded:
		return
	if $VisibilityNotifier2D.is_on_screen():
		EventBus.emit_signal("on_fuelcan_explode", global_position)

	var explosion := preload("res://scenes/Entities/Explosion/Explosion.tscn").instance() as Explosion
	add_child(explosion)
	explosion.create_big_explosion()
	explosion.connect("explosion_complete", self, "on_explosion_complete")
	$Area2D/CollisionShape2D.disabled = true
	set_collision_mask_bit(5, false)
	exploded = true
	$Sprite.visible = false

func on_explosion_complete() -> void:
	call_deferred("queue_free")

func on_player_death() -> void:
	set_process(false)
	set_physics_process(false)
	linear_velocity = Vector2(rand_range(-10.0,10.0),10.0)

func set_fuelamount(new_amount : float):
	fuel_amount = max(0.0, new_amount)

	if fuel_amount > 0.0:
		EventBus.emit_signal("fuel_changed", fuel_amount)
	else:
		EventBus.emit_signal("fuel_emptied")

func _on_Area2D_body_entered(body):
	if (body is Projectile):
		explode()
		return
	
	if !can_pickup:
		return

	if !(body is Player):
		return

	var p = body as Player
	var fuelcan = p.get_fuelcan()
	
	if fuelcan:
		if fuelcan.fuel_amount >= Global.MAX_FUEL_LITERS:
			return

		fuelcan.fuel_amount += fuel_amount
		EventBus.emit_signal("play_sound", SoundPickUp, global_position)
		queue_free()
		return

	p.connect("on_search_start", self, "on_action_pickup")
	show_label(true)

func _on_Area2D_body_exited(body):
	if !can_pickup:
		return
		
	if !(body is Player):
		return

	var p = body as Player
	p.disconnect("on_search_start", self, "on_action_pickup")
	show_label(false)

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

	EventBus.emit_signal("fuel_pickedup", fuel_amount)
	EventBus.emit_signal("play_sound", SoundPickUp, player.global_position)

func on_use(mob := null) -> void:
	$AudioStreamPlayer.stream = SoundFlow
	$AudioStreamPlayer.play()

func on_use_stop(mob := null) -> void:
	$AudioStreamPlayer.stream = SoundFlowStop
	$AudioStreamPlayer.play()

func queue_free() -> void:
	if $AudioStreamPlayer.playing:
		yield($AudioStreamPlayer,"finished")
	.queue_free()

func show_label(_visible) -> void:
	var _text := ""

	if _visible:
		var button = InputMap.get_action_list("action_alt")[0].as_text()

		if Global.GameOptions.gameplay.joypad:
			button = "action"

		_text = "[center]Press [color=#fffc00]{0}[/color] to pickup [color=#fffc00]fuel can[/color][/center]".format({0:button})

	EventBus.emit_signal("on_tooltip", _text)
