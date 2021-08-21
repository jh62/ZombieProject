class_name StateMachine

var owner : Node2D
var current_state : State

func _init(owner : Node2D) -> void:
	self.owner = owner

func update(delta: float) -> void:
	current_state.update(delta)

func input(event: InputEvent) -> void:
	current_state.input(event)

func travel_to(new_state : State) -> void:
	if current_state != null:
		current_state.exit_state()
	current_state = new_state
	current_state.enter_state()
