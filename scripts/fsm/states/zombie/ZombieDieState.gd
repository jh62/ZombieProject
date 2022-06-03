class_name ZombieDieState extends State

const SOUNDS := [
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_0.wav"),
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_1.wav"),
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_2.wav"),
	preload("res://assets/sfx/mobs/zombie/die/zombie_die_3.wav"),
]

const SoundZombieDown := [
	preload("res://assets/sfx/mobs/zombie/misc/zombie_down_1.wav"),
	preload("res://assets/sfx/mobs/zombie/misc/zombie_down_2.wav")
]

const SoundImpactFlesh := [
	preload("res://assets/sfx/impact/flesh_impact_1.wav"),
	preload("res://assets/sfx/impact/flesh_impact_2.wav"),
]

const SoundHeadshot := [
	preload("res://assets/sfx/impact/headshot_1.wav"),
]

const Guts := preload("res://scenes/Entities/Items/Guts/Guts.tscn")

var dead_time := rand_range(5.0,18.0)

var can_raise
var elapsed := 0.0

func _init(owner).(owner):
	pass

func get_name():
	return "die"

func enter_state(args) -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)

	anim_p.connect("animation_started", self, "_on_animation_started")
	anim_p.connect("animation_finished", self, "_on_animation_finished")

	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaBody/CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaPerception/CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("SoftCollision/CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AttackArea/CollisionShape2D").set_deferred("disabled", true)
	
	elapsed = 0.0
	owner.down_times += 1
	
	can_raise = Global.GameOptions.gameplay.difficulty == Globals.Difficulty.HARD && owner.down_times < 3
	
	if args != null:
		if args.has("melee_type"):
			var melee_type = args.melee_type
			
			match melee_type:
				MeleeWeapon.MeleeType.EDGED:
					anim_p.play("die_sliced_{1}".format({0:get_name(),1:facing}))
				MeleeWeapon.MeleeType.BLUNT:
					anim_p.play("headshot_{1}".format({0:get_name(),1:facing}))
				_:
					anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
			
			can_raise = false
			EventBus.emit_signal("on_object_spawn", Guts, owner.global_position)
			EventBus.emit_signal("play_sound_random", SoundImpactFlesh, owner.global_position)
		elif args.has("headshot"):
			can_raise = false
			anim_p.play("headshot_{1}".format({0:get_name(),1:facing}))
			EventBus.emit_signal("play_sound_random", SoundHeadshot, owner.global_position)
	else:
		anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	
	if !can_raise:
		owner.hitpoints = 0
		
		if 0.18 < randf():
			return
			
		EventBus.emit_signal("on_object_spawn", Guts, owner.global_position)
		
	EventBus.emit_signal("play_sound_random", SOUNDS, owner.global_position)

func update(delta) -> void:
	if !can_raise:
		return
		
	if elapsed >= dead_time:
		owner.fsm.travel_to(owner.states.standup, null)
		return

	elapsed += delta

func _on_animation_started(anim : String) -> void:
	EventBus.emit_signal("play_sound_random", SoundZombieDown, owner.global_position)

func _on_animation_finished(anim : String) -> void:
	if can_raise:
		return

	if !Global.GameOptions.graphics.corpses_decay:
		owner.set_process(false)

	owner.set_physics_process(false)
