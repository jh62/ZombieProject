extends Mobile

export var target : NodePath

func _ready() -> void:
	fsm.current_state = preload("res://scripts/fsm/states/RunState.gd").new(self)
	dir = Vector2(-1,0)

func _process(delta: float) -> void:
	._process(delta)

	if target == null:
		return

	if hitpoints <= 0:
		return

	var t := get_node(target)

	dir = global_position.direction_to(t.global_position).normalized()

	if dir.x != 0:
		facing.x = dir.x
		if dir.y == 0:
			facing.y = 0

	if dir.y != 0:
		if dir.x == 0:
			facing.x = 0
		facing.y = dir.y

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

	if anim_p.current_animation != current_anim:
		var backwards := (facing-dir).length() > 1.4 && facing != dir
		anim_p.play(current_anim)

func on_hit(attacker) -> void:
	hitpoints -= 1

	if !is_alive():
		var die_state := preload("res://scripts/fsm/states/DieState.gd").new(self)
		fsm.travel_to(die_state)
