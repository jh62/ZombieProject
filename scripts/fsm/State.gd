class_name State

var owner : Node2D

func _init(owner) -> void:
	self.owner = owner

# The name of the State should be the same as the beggining of the animation name that corresponds to it.
func get_name():
	pass

func enter_state() -> void:
	pass

func exit_state() -> void:
	pass

func update(delta) -> void:
	pass

func input(input : InputEvent) -> void:
	pass
