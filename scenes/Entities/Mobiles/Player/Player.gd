class_name Player extends Mobile

signal on_search_start
signal on_search_end

const States := {
	"idle": preload("res://scripts/fsm/states/IdleState.gd"),
	"run": preload("res://scripts/fsm/states/RunState.gd"),
	"die": preload("res://scripts/fsm/states/DieState.gd")
}

onready var equipment := $Equipment

func _ready() -> void:
	add_to_group(Global.GROUP_PLAYER)
	var current_state = States.idle.new(self)
	fsm.current_state = current_state
	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")

func _process(delta: float) -> void:
	._process(delta)
	_process_input()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		EventBus.emit_signal("action_pressed", EventBus.ActionEvent.USE, facing)
		return
	elif event.is_action_released("action"):
		EventBus.emit_signal("action_released", EventBus.ActionEvent.USE, facing)
		return
		
	if event.is_action_pressed("reload"):
		EventBus.emit_signal("action_pressed", EventBus.ActionEvent.RELOAD, facing)
		return
	
	if event.is_action_pressed("action_alt"):
		$ProgressWheel.start()
		emit_signal("on_search_start")
		return
	elif event.is_action_released("action_alt"):
		$ProgressWheel.stop()
		emit_signal("on_search_end")
		return
		
const look_at_dir := Vector2()

func _process_input() -> void:
	dir.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	dir.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	var equipped := get_equipped() as BaseItem
	
	if equipped.in_use:
		var m_pos := global_position.direction_to(get_global_mouse_position())
		look_at_dir.x = m_pos.x
		look_at_dir.y = m_pos.y
	else:
		look_at_dir.x = dir.x
		look_at_dir.y = dir.y
		
	if look_at_dir.dot(dir) < 0:
		speed = max_speed * .25
	else:
		speed = max_speed
		
	var epsilon := .15

	if look_at_dir.x < -epsilon || look_at_dir.x > epsilon:
		facing.x = look_at_dir.x
		if look_at_dir.y > -epsilon && look_at_dir.y < epsilon:
			facing.y = 0

	if look_at_dir.y < -epsilon || look_at_dir.y > epsilon:
		if look_at_dir.x > -epsilon && look_at_dir.x < epsilon:
			facing.x = 0
		facing.y = look_at_dir.y

	sprite.flip_h = facing.x < 0

func on_hit(attacker) -> void:
	if attacker.is_in_group(Globals.GROUP_ZOMBIE):
		vel *= vel * attacker.dir
		var die_state = States.die.new(self)
		fsm.travel_to(die_state)

func get_equipped():
	return equipment.get_child(0)

func _on_item_pickedup(item : BaseItem) -> void:
	equipment.equip(item)

func _on_ProgressWheel_on_progress_complete():
	$ProgressWheel.stop()
	emit_signal("on_search_end")
