class_name ZombieHeadshotState extends State

const SOUNDS := [
	preload("res://assets/sfx/impact/headshot_1.wav"),
	preload("res://assets/sfx/impact/headshot_2.wav"),
]

func _init(owner).(owner):
	pass

func get_name():
	return "headshot"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	anim_p.connect("animation_finished", self, "_on_animation_finished")

	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)
	EventBus.emit_signal("play_sound_random", SOUNDS, owner.global_position)

func update(delta) -> void:
	pass

func _on_animation_finished(anim : String) -> void:
	owner.set_process(false)
	owner.set_physics_process(false)
