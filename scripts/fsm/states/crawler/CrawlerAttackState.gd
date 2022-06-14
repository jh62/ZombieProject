class_name CrawlerAttackState extends State

const SOUNDS := [
	preload("res://assets/sfx/mobs/crawler/attack/crawler_attack_1.wav"),
	preload("res://assets/sfx/mobs/crawler/attack/crawler_attack_2.wav"),
	preload("res://assets/sfx/mobs/crawler/attack/crawler_attack_3.wav"),
]

const ATTACK_DISTANCE := 16

func _init(owner).(owner):
	pass

func get_name():
	return "attack"

func enter_state(args) -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.connect("animation_started", self, "_on_animation_started")
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	
	owner.target = args.target
	owner.dir = owner.global_position.direction_to(owner.target.global_position)
	
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

func update(delta) -> void:
	owner.move_and_slide(Vector2.ZERO) # this prevents getting the collision report stuck on the last attack_target

func _on_animation_started(anim : String) -> void:
	if !owner.target.is_alive():
		owner.fsm.travel_to(owner.states.idle, null)
		return

func _on_animation_finished(anim : String) -> void:
	if !owner.target.is_alive() || !(owner.target in owner.area_attack.get_overlapping_bodies()):
		owner.fsm.travel_to(owner.states.idle, null)
		return

	var target_pos = owner.target.global_position
	var target_dir = owner.global_position.direction_to(target_pos)
#	var facing_direction = target_pos.direction_to(owner.global_position).dot(target_dir) < 0
	var facing_direction = owner.dir.dot(target_dir) > 0

	if owner.is_visible_in_viewport():
		EventBus.emit_signal("play_sound_random", SOUNDS, owner.global_position)

	if facing_direction:
		owner.target.on_hit_by(owner)

	owner.fsm.travel_to(owner.states.idle, null)
