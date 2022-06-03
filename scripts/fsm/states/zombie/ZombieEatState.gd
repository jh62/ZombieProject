class_name ZombieEatState extends State

const Guts := preload("res://scenes/Entities/Items/Guts/Guts.tscn")

const Sounds := [
	preload("res://assets/sfx/misc/squish_1.wav"),
	preload("res://assets/sfx/misc/squish_2.wav"),
	preload("res://assets/sfx/misc/squish_3.wav"),
]

var corpse

func _init(owner).(owner):
	pass

func get_name():
	return "eat"

func enter_state(args) -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := "s" if owner.facing.y > 0 else "n"

	owner.target = null
	owner.waypoints = []
	owner.dir = Vector2.ZERO
	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	corpse = args.corpse
	corpse.is_eaten = true

	EventBus.emit_signal("play_sound_random", owner.sounds.eating, owner.global_position)
	anim_p.queue("{0}_{1}".format({0:get_name(),1:facing}))

func exit_state() -> void:
	owner.get_node("CollisionShape2D").set_deferred("disabled", false)

var elapsed := 0.0
var eat_time := rand_range(12,18)

func update(delta) -> void:
	if elapsed >= eat_time:
		owner.fsm.travel_to(owner.states.idle, null)
		return

	elapsed += delta
	owner.vel = owner.move_and_slide(Vector2.ZERO)
	
	if 0.017 > randf():
		var guts := Guts.instance()
		EventBus.emit_signal("on_object_spawn", guts, corpse.global_position + Vector2(cos(2.0),sin(2.0)) * 2.0, -1)
		EventBus.emit_signal("play_sound_random",Sounds, owner.global_position)
