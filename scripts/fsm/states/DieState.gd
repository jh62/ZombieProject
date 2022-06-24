class_name DieState extends State

const SOUNDS := [
	preload("res://assets/sfx/mobs/player/die/player_die_1.wav"),
	preload("res://assets/sfx/mobs/player/die/player_die_2.wav"),
	preload("res://assets/sfx/mobs/player/die/player_die_3.wav"),
]

const RESURRECTION_DELAY := 5.0

var _dead_elapsed := 0.0

func _init(owner).(owner):
	pass

func get_name():
	return "die"

func enter_state(args) -> void:
	var anim_name = get_name()
	var anim_data := Mobile.get_facing_as_string(owner.facing)
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})

	var anim_p = owner.get_anim_player()
	anim_p.play(current_anim)
	
	_dead_elapsed = 0.0

	owner.hitpoints = 0
	owner.down_times += 1
	owner.set_process_unhandled_input(false)

	if owner.equipment != null:
		owner.equipment.set_process(false)
		owner.equipment.visible = false
		
	if owner.down_times > 1 || !PlayerStatus.has_perk(Perk.PERK_TYPE.ADRENALINE):
		owner.set_process(false)
		owner.set_physics_process(false)
		owner.get_node("CollisionShape2D").disabled = true

	EventBus.emit_signal("play_sound_random", SOUNDS, owner.global_position)

func update(delta) -> void:
	_dead_elapsed += delta
	
	if _dead_elapsed >= RESURRECTION_DELAY:
		owner.set_process(true)
		owner.set_physics_process(true)
		owner.get_node("CollisionShape2D").disabled = false
		
		if owner.equipment != null:
			owner.equipment.set_process(true)
			owner.equipment.visible = true
			
		owner.hitpoints = owner.max_hitpoints
		owner.set_process_unhandled_input(true)
			
		owner.fsm.travel_to(owner.states.idle, null)
		return
		
#	if owner.is_eaten:
#		owner.get_node("CollisionShape2D").disabled = true
#		owner.set_process(false)
#		owner.set_physics_process(false)
