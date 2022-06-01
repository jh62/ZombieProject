class_name StateMachine

var owner : Node2D
var current_state : State

func _init(_owner : Node2D) -> void:
	self.owner = _owner

func update(delta: float) -> void:
	if current_state == null:
		return
		
	current_state.update(delta)

func input(event: InputEvent) -> void:
	if current_state == null:
		return
		
	current_state.input(event)

func travel_to(new_state : State, args) -> void:
	if current_state != null:
		current_state.exit_state()

	new_state.enter_state(args)
	current_state = new_state
