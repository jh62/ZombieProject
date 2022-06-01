class_name State

var owner : KinematicBody2D

func _init(_owner : KinematicBody2D) -> void:
	self.owner = _owner

# The name of the State should be the same as the beggining of the animation name that corresponds to it.
func get_name():
	pass

func enter_state(args : Dictionary) -> void:
	pass

func exit_state() -> void:
	for connection in get_incoming_connections(): #disconnects all signals from state
		connection.source.disconnect(connection.signal_name, self, connection.method_name)

func update(_delta) -> void:
	pass

func input(_input : InputEvent) -> void:
	pass
