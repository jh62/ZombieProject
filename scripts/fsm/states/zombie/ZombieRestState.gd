class_name ZombieRestState extends State

var elapsed := 0.0

func _init(owner).(owner):
	pass

func get_name():
	return "rest"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)
	anim_p.play("die_{0}".format({0:facing}))

#	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
#	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)

func update(delta) -> void:
	if owner.target == null:
		return
	if !owner.is_visible_in_viewport():
		return

	if elapsed >= 2.0:
		if owner.target is Vector2 || owner.area_perception.overlaps_body(owner.target):
			var new_state = owner.States.standup.new(owner)
			owner.fsm.travel_to(new_state)
			return

	elapsed += delta
