class_name ZombieEatState extends State

var corpse : Mobile

func _init(owner, _corpse).(owner):
	corpse = _corpse

func get_name():
	return "eat"

func enter_state() -> void:	
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)	
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	
	owner.target = null
	owner.dir = Vector2.ZERO
	

func exit_state() -> void:
	pass

var elapsed := 0.0
var eat_time := rand_range(3.0,7.5)

func update(delta) -> void:
	if elapsed >= eat_time:
		var new_state := ZombieIdleState.new(owner)
		owner.fsm.travel_to(new_state)
		return
		
	elapsed += delta
	owner.vel = owner.move_and_slide(Vector2.ZERO)
