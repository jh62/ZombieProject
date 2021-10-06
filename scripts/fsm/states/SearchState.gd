class_name SearchState extends State

func _init(owner).(owner):
	pass

func get_name():
	return "search"

func enter_state() -> void:
	var anim_name = get_name()
	var anim_data := Mobile.get_facing_as_string(owner.facing)
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})

	var anim_p = owner.get_anim_player()
	anim_p.play(current_anim)
	owner.equipment.visible = false

func exit_state() -> void:
	owner.equipment.visible = true

func update(delta) -> void:
	owner.vel = owner.move_and_slide(Vector2.ZERO)
