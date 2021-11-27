class_name ZombieMeleeState extends State

const SOUNDS := {
	"edged":[
		preload("res://assets/sfx/impact/melee/blade_hit_1.wav"),
		preload("res://assets/sfx/impact/melee/blade_hit_2.wav"),
		preload("res://assets/sfx/impact/melee/blade_hit_3.wav"),
	],
	"blunt":[
		preload("res://assets/sfx/impact/melee/blunt_hit_1.wav"),
		preload("res://assets/sfx/impact/melee/blunt_hit_2.wav"),
		preload("res://assets/sfx/impact/melee/blunt_hit_3.wav"),
	],
	"impact_flesh":[
		preload("res://assets/sfx/impact/flesh_impact_01.wav"),
		preload("res://assets/sfx/impact/flesh_impact_02.wav"),
	]
}

var melee_type

func _init(owner, _melee_type).(owner):
	melee_type = _melee_type

func get_name():
	return "melee"

func enter_state() -> void:
	var anim_name : String
	var sounds

	match melee_type:
		MeleeWeapon.MeleeType.EDGED:
			anim_name = "die_sliced"
			sounds = SOUNDS.edged
		_:
			anim_name = "headshot"
			sounds = SOUNDS.blunt

	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:anim_name,1:facing}))
	anim_p.connect("animation_finished", self, "_on_animation_finished")

	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)
	EventBus.emit_signal("play_sound_random", sounds, owner.global_position)

func update(delta) -> void:
	pass

func _on_animation_finished(anim : String) -> void:
	owner.set_process(false)
	owner.set_physics_process(false)
