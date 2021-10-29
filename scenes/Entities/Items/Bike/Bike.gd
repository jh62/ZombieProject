class_name Bike extends KinematicBody2D

signal on_full_tank
signal on_fuel_changed(amount)

export var fuel_amount := 0.0 setget set_fuel_amount

var player
var fuelcan

func _ready():
	$Area2D/CollisionShape2D.shape = $CollisionShape2D.shape

func set_fuel_amount(new_amount) -> void:
	fuel_amount = clamp(fuel_amount + new_amount, 0.0, Globals.MAX_FUEL_LITERS)

	if fuel_amount >= Globals.MAX_FUEL_LITERS:
		emit_signal("on_full_tank")
		return

func _on_body_entered(body):
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

func on_player_action_start(_player) -> void:
	$Timer.start()

func on_player_action_end(_player) -> void:
	$Timer.stop()

func _on_Timer_timeout():
	if player == null || !player.is_alive() || fuelcan == null || fuelcan.fuel_amount == 0.0 || fuel_amount >= Globals.MAX_FUEL_LITERS:
		$Timer.stop()
		return

	self.fuel_amount += .15
	fuelcan.fuel_amount -= .15

	if fuelcan.fuel_amount == 0.0:
		fuelcan.queue_free()
		fuelcan = null
		$Timer.stop()

	emit_signal("on_fuel_changed", fuel_amount)
