class_name DieState extends State

const SOUNDS := [
	preload("res://assets/sfx/mobs/player/die/player_die_1.wav"),
	preload("res://assets/sfx/mobs/player/die/player_die_2.wav"),
	preload("res://assets/sfx/mobs/player/die/player_die_3.wav"),
]

func _init(owner).(owner):
	pass

func get_name():
	return "die"

func enter_state() -> void:
	var anim_name = get_name()
	var anim_data := Mobile.get_facing_as_string(owner.facing)
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})

	var anim_p = owner.get_anim_player()
	anim_p.play(current_anim)

	owner.hitpoints = 0
	owner.set_process_unhandled_input(false)

	if owner.equipment != null:
		owner.equipment.set_process(false)
		owner.equipment.visible = false

	EventBus.emit_signal("play_sound_random", SOUNDS, owner.global_position)

func update(delta) -> void:
	if round(owner.vel.length()) >= 0.0:
		owner.vel = owner.move_and_slide(owner.vel)
		owner.vel *= .9

	if owner.is_eaten:
		owner.get_node("CollisionShape2D").disabled = true
		owner.set_process(false)
		owner.set_physics_process(false)
