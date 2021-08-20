extends Node2D

func _ready() -> void:
	pass

func equip(item : BaseItem) -> void:
	var child : BaseItem = get_child(0)

	if child != null:
		child.queue_free()

	add_child(item)

func _process(delta: float) -> void:
	var owner := self.owner as Player
	var child : BaseItem = get_child(0)
	child.state = owner.fsm.current_state
	child.facing = owner.facing
