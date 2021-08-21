class_name Player extends Mobile

onready var equipment := $Equipment

func _ready() -> void:
	var current_state = preload("res://scripts/fsm/states/IdleState.gd").new(self)
	fsm.current_state = current_state
	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")

func _process(delta: float) -> void:
	._process(delta)
	_process_input()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		EventBus.emit_signal("action_pressed", facing)
	elif event.is_action_released("action"):
		EventBus.emit_signal("action_released", facing)

func _process_input() -> void:
	var look_at_dir := global_position.direction_to(get_global_mouse_position())

	dir.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	dir.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	var epsilon := .15

	if look_at_dir.x < -epsilon || look_at_dir.x > epsilon:
		facing.x = look_at_dir.x
		if look_at_dir.y > -epsilon && look_at_dir.y < epsilon:
			facing.y = 0.0

	if look_at_dir.y < -epsilon || look_at_dir.y > epsilon:
		if look_at_dir.x > -epsilon && look_at_dir.x < epsilon:
			facing.x = 0.0
		facing.y = look_at_dir.y

	var flip_h := facing.x < 0
	sprite.flip_h = flip_h

	var anim_name = fsm.current_state.get_name()
	var anim_data := Mobile.get_facing_as_string(facing)
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})
	anim_p.play(current_anim)

func _on_item_pickedup(item : BaseItem) -> void:
	equipment.equip(item)
