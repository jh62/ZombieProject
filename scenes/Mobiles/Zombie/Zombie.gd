extends Mobile

export var target : NodePath

func _ready() -> void:
	fsm.current_state = preload("res://scripts/fsm/states/RunState.gd").new()
	dir = Vector2(-1,0)

func _process(delta: float) -> void:
	._process(delta)

	if target == null:
		return

	var t := get_node(target)

	dir = global_position.direction_to(t.global_position).normalized()
	var look_at_dir := dir

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
