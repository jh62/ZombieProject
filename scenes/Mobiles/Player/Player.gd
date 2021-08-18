class_name Player extends Mobile

onready var arms := $Arms

func _ready() -> void:
	fsm.current_state = preload("res://scripts/fsm/states/IdleState.gd").new()
	var item = load("res://scenes/Items/Weapon/Disarmed.gd").new()
	arms.set_item(item)

func _process(delta: float) -> void:
	._process(delta)
	_process_input()
	arms.update_frame(sprite.frame, sprite.hframes, sprite.vframes, sprite.flip_h)

func _process_input() -> void:
	var look_at_dir := global_position.direction_to(get_global_mouse_position()).round()

	dir.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	dir.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	if look_at_dir.x != 0:
		facing.x = look_at_dir.x
		if look_at_dir.y == 0:
			facing.y = 0

	if look_at_dir.y != 0:
		if look_at_dir.x == 0:
			facing.x = 0
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

	var anim_name = fsm.current_state.get_name()
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})

	if anim.current_animation != current_anim:
		var backwards := (facing-dir).length() > 1.4 && facing != dir
		call_deferred("_set_animations", current_anim, backwards)

func _set_animations(anim_name, backwards := false) -> void:
	._set_animations(anim_name, backwards)
	arms.set_animation(fsm.current_state)
