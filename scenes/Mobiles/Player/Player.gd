class_name Player extends Mobile

onready var arms := $Arms

func _ready() -> void:
	fsm.current_state = preload("res://scripts/fsm/states/IdleState.gd").new()
	var item = preload("res://scenes/Items/Weapon/Disarmed.gd").new()
	arms.set_item(item)
	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")

func _process(delta: float) -> void:
	._process(delta)
	_process_input()
	arms.update_frame(sprite.frame, sprite.hframes, sprite.vframes, sprite.flip_h)

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

	var anim_data : String

	if facing.y < 0:
		anim_data += "n"
	elif facing.y > 0:
		anim_data += "s"

	if facing.x != 0:
		anim_data += "e"

	if anim_data.empty():
		anim_data = "e"

	sprite.flip_h = facing.x < 0

	var is_action_pressed := Input.is_action_pressed("action")

	var anim_name = fsm.current_state.get_name()
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})

	if anim.current_animation != current_anim:
#		var backwards := (facing-dir).length() > 1.4 && facing != dir
		anim.play(current_anim)
		if !is_action_pressed:
			arms.set_animation(fsm.current_state.get_name())

	if is_action_pressed:
		arms.set_animation("action")

func _on_item_pickedup(item : BaseItem) -> void:
	arms.set_item(item)
	arms.set_animation(fsm.current_state.get_name())
