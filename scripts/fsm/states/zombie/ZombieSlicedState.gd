class_name ZombieSlicedState extends State

const SOUNDS := [
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_0.wav"),
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_1.wav"),
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_2.wav"),
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_3.wav"),
]

const Guts := preload("res://scenes/Entities/Items/Guts/Guts.tscn")

func _init(owner).(owner):
	pass

func get_name():
	return "die_sliced"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)

	EventBus.emit_signal("on_object_spawn", Guts, owner.global_position)
	EventBus.emit_signal("play_sound_random", SOUNDS, owner.global_position)

func exit_state() -> void:
	pass

func update(delta) -> void:
	pass
