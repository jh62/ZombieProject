class_name ZombieDieState extends State

const DEATH_SOUNDS := [
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_0.wav"),
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_1.wav"),
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_2.wav"),
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_3.wav"),
]

func _init(owner).(owner):
	pass

func get_name():
	return "die"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)	
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	
	owner.get_node("CollisionShape2D").disabled = true	
	owner.set_process(false)
	owner.set_physics_process(false)
	SoundManager.play_sound_pool(DEATH_SOUNDS, owner.global_position)

func update(delta) -> void:
	pass
