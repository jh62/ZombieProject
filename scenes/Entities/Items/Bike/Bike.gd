class_name Bike extends KinematicBody2D

signal on_full_tank
signal on_fuel_changed(amount)

export var fuel_amount := 0.0 setget set_fuel_amount

var player
var fuelcan
var weapon

func _ready():
	pass

func set_fuel_amount(new_amount) -> void:
	fuel_amount = min(new_amount, Globals.MAX_FUEL_LITERS)

	if fuel_amount >= Globals.MAX_FUEL_LITERS:
		stop()
		emit_signal("on_full_tank")
		return

func on_player_action_start(_player : Node2D) -> void:
	if fuelcan == null:
		return

	start()

func on_player_action_end(_player : Node2D) -> void:
	if fuelcan == null:
		return
	stop()

func _on_Timer_timeout():
	if player == null || !player.is_alive() || fuelcan == null || fuel_amount >= Globals.MAX_FUEL_LITERS:
		$Timer.stop()
		return

	player.can_move = false

	self.fuel_amount += .15
	fuelcan.fuel_amount -= .15

	if fuelcan.fuel_amount == 0.0:
		stop()
		fuelcan.call_deferred("queue_free")
		fuelcan = null

	emit_signal("on_fuel_changed", fuel_amount)

func _on_Area2D_body_entered(body):
	var _player = body as Player
	var _fuelcan = _player.find_node("FuelCan*",false, false)

	if _fuelcan == null:
		return

	fuelcan = _fuelcan

	player = _player
	player.connect("on_search_start", self, "on_player_action_start")
	player.connect("on_search_end", self, "on_player_action_end")

func _on_Area2D_body_exited(body):
	var _player = body as Player

	player = _player
	player.disconnect("on_search_start", self, "on_player_action_start")
	player.disconnect("on_search_end", self, "on_player_action_end")

	stop()

func start() -> void:
	if !$Timer.is_stopped():
		return

	weapon = player.equipment.get_child(0)
	player.equipment.remove_child(weapon)

	var disarmed := preload("res://scenes/Entities/Items/Weapon/Disarmed/Disarmed.tscn").instance()
	player.equipment.equip(disarmed)

	player.can_move = false
	fuelcan.on_use()
	$Timer.start()

func stop() -> void:
	if $Timer.is_stopped():
		return

	player.equipment.clear()
	player.equipment.add_child(weapon)

	player.can_move = true
	fuelcan.on_use_stop()
	$Timer.stop()
