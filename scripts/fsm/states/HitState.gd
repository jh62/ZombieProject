class_name HitState extends State

const HitSounds := [
	preload("res://assets/sfx/impact/body_hit_1.wav"),
	preload("res://assets/sfx/impact/body_hit_2.wav"),
	preload("res://assets/sfx/impact/body_hit_3.wav"),
	preload("res://assets/sfx/impact/body_hit_4.wav"),
]

const HurtSounds := [
	preload("res://assets/sfx/mobs/player/hurt/player_hurt_0.wav"),
	preload("res://assets/sfx/mobs/player/hurt/player_hurt_1.wav"),
	preload("res://assets/sfx/mobs/player/hurt/player_hurt_2.wav"),
	preload("res://assets/sfx/mobs/player/hurt/player_hurt_3.wav"),
]

var attacker : Node2D

func _init(owner, _attacker).(owner):
	attacker = _attacker

func get_name():
	return "hit"

func enter_state() -> void:
	var anim_name = get_name()
	var anim_data := Mobile.get_facing_as_string(owner.facing)
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})

	var anim_p = owner.get_anim_player()
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	anim_p.play(current_anim)

	owner.vel += attacker.dir * 2.2
	EventBus.emit_signal("play_sound_random", HitSounds, owner.global_position)

	if .45 > randf():
		EventBus.emit_signal("play_sound_random", HurtSounds, owner.global_position)

func update(delta) -> void:
	owner.vel = owner.move_and_slide(owner.vel)

func _on_animation_finished(anim : String) -> void:
	var new_state = owner.States.idle.new(owner)
	owner.fsm.travel_to(new_state)
