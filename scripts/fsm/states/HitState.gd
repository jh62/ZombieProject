class_name HitState extends State

var attacker : Mobile

func _init(owner, _attacker).(owner):
	attacker = _attacker

func get_name():
	return "hit"

func enter_state() -> void:
	var anim_name = get_name()
	var anim_data := Mobile.get_facing_as_string(owner.facing)
	var current_anim := "{0}_{1}".format({0:anim_name,1:anim_data})

	var anim_p = owner.get_anim_player()
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	anim_p.play(current_anim)

	owner.vel += attacker.dir * 2.2

func update(delta) -> void:
	owner.vel = owner.move_and_slide(owner.vel)

func _on_animation_finished(anim : String) -> void:
	var new_state = owner.States.idle.new(owner)
	owner.fsm.travel_to(new_state)
