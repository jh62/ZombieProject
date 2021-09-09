class_name Player extends Mobile

const States := {
	"idle": preload("res://scripts/fsm/states/IdleState.gd"),
	"run": preload("res://scripts/fsm/states/RunState.gd"),
	"die": preload("res://scripts/fsm/states/DieState.gd")
}

onready var equipment := $Equipment

func _ready() -> void:
	var current_state = States.idle.new(self)
	fsm.current_state = current_state
	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")

func _process(delta: float) -> void:
	._process(delta)
	_process_input()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		EventBus.emit_signal("action_pressed", EventBus.ActionEvent.USE, facing)
	elif event.is_action_pressed("reload"):
		EventBus.emit_signal("action_pressed", EventBus.ActionEvent.RELOAD, facing)
	elif event.is_action_released("action"):
		EventBus.emit_signal("action_released", EventBus.ActionEvent.USE, facing)

func _process_input() -> void:
	var look_at_dir : Vector2
	var equipped := get_equipped() as BaseItem
	
	if equipped.in_use:
		look_at_dir = global_position.direction_to(get_global_mouse_position())
		dir = Vector2.ZERO
	else:		
		look_at_dir.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		look_at_dir.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		dir = look_at_dir
		
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
	
	var anim_p := get_anim_player()
	anim_p.play(current_anim)

func on_hit(attacker) -> void:
	if attacker.is_in_group(Globals.GROUP_ZOMBIE):
		vel *= vel * attacker.dir
		var die_state = States.die.new(self)
		fsm.travel_to(die_state)

func get_equipped():
	return equipment.get_child(0)

func _on_item_pickedup(item : BaseItem) -> void:
	equipment.equip(item)
