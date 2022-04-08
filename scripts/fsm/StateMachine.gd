class_name StateMachine

var owner : Node2D
var current_state : State

func _init(_owner : Node2D) -> void:
	self.owner = _owner

func update(delta: float) -> void:
	current_state.update(delta)

func input(event: InputEvent) -> void:
	current_state.input(event)

func travel_to(new_state : State) -> void:
	if current_state != null:
		current_state.exit_state()

	new_state.enter_state()
	current_state = new_state
