class_name ZombieHitState extends State

const SOUNDS := {
	"bullet_impact":[
		preload("res://assets/sfx/impact/bullet_body_1.wav"),
		preload("res://assets/sfx/impact/bullet_body_2.wav"),
		preload("res://assets/sfx/impact/bullet_body_3.wav"),
		preload("res://assets/sfx/impact/bullet_body_4.wav"),
	],
	"body_impact":[
		preload("res://assets/sfx/impact/body_hit_1.wav"),
		preload("res://assets/sfx/impact/body_hit_2.wav"),
		preload("res://assets/sfx/impact/body_hit_3.wav"),
		preload("res://assets/sfx/impact/body_hit_4.wav"),
	],
	"hurt":[
		preload("res://assets/sfx/mobs/zombie/hurt/zombie_hurt_1.wav"),
		preload("res://assets/sfx/mobs/zombie/hurt/zombie_hurt_2.wav"),
		preload("res://assets/sfx/mobs/zombie/hurt/zombie_hurt_3.wav"),
		preload("res://assets/sfx/mobs/zombie/hurt/zombie_hurt_4.wav"),
	]
}

var attacker

func _init(owner, _attacker).(owner):
	attacker = _attacker

func get_name():
	return "hit"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)

	if "knockback" in attacker:
		owner.vel *= -(attacker.knockback * .25)

	if attacker is Projectile:
		EventBus.emit_signal("play_sound_random", SOUNDS.bullet_impact, owner.global_position)
	else:
		EventBus.emit_signal("play_sound_random", SOUNDS.body_impact, owner.global_position)

	EventBus.emit_signal("play_sound_random", SOUNDS.hurt, owner.global_position)

func update(delta) -> void:
	owner.vel = owner.move_and_slide(owner.vel) # this prevents getting the collision report stuck on the last collider

func _on_animation_finished(anim : String) -> void:
	owner.fsm.travel_to(owner.States.idle.new(owner))
