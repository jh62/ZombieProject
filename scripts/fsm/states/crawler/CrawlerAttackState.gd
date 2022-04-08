class_name CrawlerAttackState extends State

const SOUNDS := [
	preload("res://assets/sfx/mobs/crawler/attack/crawler_attack_1.wav"),
	preload("res://assets/sfx/mobs/crawler/attack/crawler_attack_2.wav"),
	preload("res://assets/sfx/mobs/crawler/attack/crawler_attack_3.wav"),
]

const ATTACK_DISTANCE := 16

var attack_target : Player

func _init(owner, _attack_target).(owner):
	attack_target = _attack_target

func get_name():
	return "attack"

func enter_state() -> void:
	owner.dir = owner.global_position.direction_to(attack_target.global_position)

	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.connect("animation_started", self, "_on_animation_started")
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

func update(delta) -> void:
	owner.move_and_slide(Vector2.ZERO) # this prevents getting the collision report stuck on the last attack_target

func _on_animation_started(anim : String) -> void:
	if !attack_target.is_alive():
		owner.fsm.travel_to(owner.States.idle.new(owner))
		return

#	owner.facing = owner.global_position.direction_to(attack_target.global_position)
#	owner.dir = owner.facing2
#	print_debug(owner.facing)

func _on_animation_finished(anim : String) -> void:
	if !attack_target.is_alive() || !(attack_target in owner.area_attack.get_overlapping_bodies()):
		var next_state = owner.States.idle.new(owner)
		owner.fsm.travel_to(next_state)
		return

	var target_pos := attack_target.global_position
	var target_dir := owner.global_position.direction_to(target_pos).round()
	var facing_direction = target_pos.direction_to(owner.global_position).dot(target_dir) < 0

	if owner.is_visible_in_viewport():
		EventBus.emit_signal("play_sound_random", SOUNDS, owner.global_position)

	if facing_direction:
		attack_target.on_hit_by(owner)
