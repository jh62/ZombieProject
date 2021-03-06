class_name Bike extends KinematicBody2D

signal on_full_tank
signal on_fuel_stopped(amount)
signal on_fuel_changed(amount)

const STEP := 0.1

export var fuel_amount := 0.0 setget set_fuel_amount
export var can_refuel := true

var player
var fuelcan
var weapon

func _ready():
	pass

func set_fuel_amount(new_amount) -> void:
	fuel_amount = min(new_amount, Globals.MAX_FUEL_LITERS)

	if fuel_amount >= Globals.MAX_FUEL_LITERS:
		stop()
		EventBus.emit_signal("on_bike_tank_full")
		return

func on_player_action_start(_player : Node2D) -> void:
	if fuelcan == null || !can_refuel:
		return

	start()

func on_player_action_end(_player : Node2D) -> void:
	if fuelcan == null || !can_refuel:
		return
	stop()

func _on_Timer_timeout():
	if player == null || !player.is_alive() || fuelcan == null || fuel_amount >= Globals.MAX_FUEL_LITERS:
		$Timer.stop()
		return

	player.can_move = false

	self.fuel_amount += STEP
	fuelcan.fuel_amount -= STEP

	if fuelcan.fuel_amount == 0.0:
		stop()
		fuelcan.call_deferred("queue_free")
		fuelcan = null
		emit_signal("on_fuel_stopped", fuel_amount)

	emit_signal("on_fuel_changed", fuel_amount)

func _on_Area2D_body_entered(body):
	if !can_refuel:
		return
		
	var _player = body as Player
	var _fuelcan = _player.get_fuelcan()

	if _fuelcan == null:
		return

	fuelcan = _fuelcan

	player = _player
	player.connect("on_search_start", self, "on_player_action_start")
	player.connect("on_search_end", self, "on_player_action_end")


	var _text = "[center]Press [color=#fffc00]{0}[/color] to fill the tank[/center]".format({0:InputMap.get_action_list("action_alt")[0].as_text()})
	EventBus.emit_signal("on_tooltip", _text)

func _on_Area2D_body_exited(body):
	if !can_refuel:
		return
		
	var _player = body as Player

	player = _player

	if player.is_connected("on_search_start", self, "on_player_action_start"):
		player.disconnect("on_search_start", self, "on_player_action_start")

	if player.is_connected("on_search_end", self, "on_player_action_end"):
		player.disconnect("on_search_end", self, "on_player_action_end")

	stop()

func start() -> void:
	if !$Timer.is_stopped():
		return

	player.get_equipment().disarm()

	player.can_move = false	
	player.dir = Vector2.ZERO
	player.vel = Vector2.ZERO
	fuelcan.on_use()
	$Timer.start()

func stop() -> void:
	if $Timer.is_stopped():
		return

	EventBus.emit_signal("on_tooltip", "")
	player.get_equipment().equip_primary()

	player.can_move = true
	fuelcan.on_use_stop()
	$Timer.stop()
