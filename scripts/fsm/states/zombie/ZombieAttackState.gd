class_name ZombieAttackState extends State

const SOUNDS := [
	preload("res://assets/sfx/mobs/zombie/attack/zombie_attack_0.wav"),
	preload("res://assets/sfx/mobs/zombie/attack/zombie_attack_1.wav"),
	preload("res://assets/sfx/mobs/zombie/attack/zombie_attack_2.wav"),
	preload("res://assets/sfx/mobs/zombie/attack/zombie_attack_3.wav"),
]

const ATTACK_DISTANCE := 16

var attack_target : Player

func _init(owner, _attack_target).(owner):
	attack_target = _attack_target

func get_name():
	return "attack"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)	
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))
	anim_p.connect("animation_finished", self, "_on_animation_finished")

func exit_state() -> void:
	pass

func update(delta) -> void:
	owner.move_and_slide(Vector2.ZERO) # this prevents getting the collision report stuck on the last attack_target

func _on_animation_finished(anim : String) -> void:
	if attack_target.is_alive():
		var target_pos := attack_target.global_position
		var target_dir := owner.global_position.direction_to(target_pos)
		var is_facing = owner.dir.dot(target_dir) > 0
		
		if is_facing:
			var dist := owner.global_position.distance_to(target_pos)
			if dist <= ATTACK_DISTANCE:
				attack_target.on_hit(owner)
				EventBus.emit_signal("play_sound_random", SOUNDS, owner.global_position)
		
	owner.fsm.travel_to(owner.States.idle.new(owner))
