class_name ZombieAttackState extends State

const ATTACK_DISTANCE := 16

var attack_target : Player

func _init(owner, _attack_target).(owner):
	attack_target = _attack_target

func get_name():
	return "attack"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.connect("animation_started", self, "_on_animation_started")
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

func update(delta) -> void:
	owner.move_and_slide(Vector2.ZERO) # this prevents getting the collision report stuck on the last attack_target

func _on_animation_started(anim : String) -> void:
	owner.dir = owner.global_position.direction_to(attack_target.global_position).round()
	
func _on_animation_finished(anim : String) -> void:
	var target_pos := attack_target.global_position
	var target_dir := owner.global_position.direction_to(target_pos)
	var is_facing = owner.dir.dot(target_dir) > 0
	
	if owner.is_visible_in_viewport():
		EventBus.emit_signal("play_sound_random", owner.sounds.attack, owner.global_position)

	if attack_target.is_alive():
		if is_facing && attack_target in owner.area_attack.get_overlapping_bodies():
			attack_target.on_hit_by(owner)
			
			if owner.zombie_type == owner.Type.FIREFIGHTER:
				EventBus.emit_signal("play_sound_random", owner.sounds.axe_hit, owner.global_position)
				

	owner.fsm.travel_to(owner.states.idle.new(owner))
