class_name ZombieEatState extends State

const SOUNDS := [
	preload("res://assets/sfx/mobs/zombie/eat/zombie_eating_1.wav")
]

var corpse : Mobile

func _init(owner, _corpse).(owner):
	corpse = _corpse

func get_name():
	return "eat"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := "s" if owner.facing.y > 0 else "n"
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.target.is_eaten = true
	owner.target = null
	owner.waypoints = []
	owner.dir = Vector2.ZERO
	EventBus.emit_signal("play_sound_random", SOUNDS, owner.global_position)

var elapsed := 0.0
var eat_time := rand_range(12,18)

func update(delta) -> void:
	if elapsed >= eat_time:
		var new_state := ZombieIdleState.new(owner)
		owner.fsm.travel_to(new_state)
		return

	elapsed += delta
	owner.vel = owner.move_and_slide(Vector2.ZERO)
