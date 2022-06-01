class_name CrawlerDieState extends State

const DeathSounds := [
	preload("res://assets/sfx/mobs/crawler/die/crawler_death.wav")
]

const SoundImpactFlesh := [
		preload("res://assets/sfx/impact/flesh_impact_1.wav"),
		preload("res://assets/sfx/impact/flesh_impact_2.wav"),
]

const Guts := preload("res://scenes/Entities/Items/Guts/Guts.tscn")

func _init(owner).(owner):
	pass

func get_name():
	return "die"

func enter_state(args) -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)

	anim_p.connect("animation_finished", self, "_on_animation_finished")

	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaPerception/CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("SoftCollision/CollisionShape2D").set_deferred("disabled", true)
	
	owner.hitpoints = 0.0
	
	if args.has("melee_type"):
		EventBus.emit_signal("on_object_spawn", Guts, owner.global_position)
		EventBus.emit_signal("play_sound_random", SoundImpactFlesh, owner.global_position)
	
	EventBus.emit_signal("play_sound", DeathSounds, owner.global_position)
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

func update(delta) -> void:
	pass

func _on_animation_finished(anim : String) -> void:
	owner.set_process(false)
	owner.set_physics_process(false)
