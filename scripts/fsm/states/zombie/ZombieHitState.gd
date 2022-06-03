class_name ZombieHitState extends State

const SOUNDS := {	
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
var last_hit = 0.0

func _init(owner).(owner):
	pass

func get_name():
	return "hit"

func enter_state(args) -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)
	
	attacker = args.attacker

	if "knockback" in attacker:
		owner.vel *= -(attacker.knockback * .25)
		
	var diff = OS.get_system_time_msecs() - last_hit

	if diff < 750:
		return

	last_hit = OS.get_system_time_msecs()
#
	EventBus.emit_signal("play_sound_random", SOUNDS.hurt, owner.global_position)
	
	if attacker is MeleeWeapon:
		EventBus.emit_signal("play_sound_random", SOUNDS.body_impact, owner.global_position)

func update(delta) -> void:
	owner.vel = owner.move_and_slide(owner.vel) # this prevents getting the collision report stuck on the last collider

func _on_animation_finished(anim : String) -> void:
	owner.fsm.travel_to(owner.states.idle, null)
	
