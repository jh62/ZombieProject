class_name ZombieMeleeDeathState extends State

const SoundImpactFlesh := [
		preload("res://assets/sfx/impact/flesh_impact_1.wav"),
		preload("res://assets/sfx/impact/flesh_impact_2.wav"),
	]

const Guts := preload("res://scenes/Entities/Items/Guts/Guts.tscn")

var melee_type

func _init(owner, _melee_type).(owner):
	melee_type = _melee_type

func get_name():
	return "melee"

func enter_state() -> void:
	var anim_name : String

	match melee_type:
		MeleeWeapon.MeleeType.EDGED:
			anim_name = "die_sliced"
		_:
			anim_name = "headshot"

	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:anim_name,1:facing}))
	anim_p.connect("animation_finished", self, "_on_animation_finished")

	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("SoftCollision/CollisionShape2D").set_deferred("disabled", true)

	EventBus.emit_signal("play_sound_random", SoundImpactFlesh, owner.global_position)

	var guts := Guts.instance()
	EventBus.emit_signal("on_object_spawn", guts, owner.global_position)

func update(delta) -> void:
	pass

func _on_animation_finished(anim : String) -> void:
	owner.set_process(false)
	owner.set_physics_process(false)
