class_name CrawlerDieState extends State

const DeathSounds := [
	preload("res://assets/sfx/mobs/crawler/die/crawler_death.wav")
]

func _init(owner).(owner):
	pass

func get_name():
	return "die"

func enter_state() -> void:
	var anim_p : AnimationPlayer = owner.get_anim_player()
	var facing := Mobile.get_facing_as_string(owner.facing)

	anim_p.connect("animation_started", self, "_on_animation_started")
	anim_p.connect("animation_finished", self, "_on_animation_finished")
	anim_p.play("{0}_{1}".format({0:get_name(),1:facing}))

	owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	owner.get_node("AreaHead/CollisionShape2D").set_deferred("disabled", true)

func update(delta) -> void:
	if !Global.GameOptions.graphics.corpses_decay:
		return

	owner.modulate.a -= 0.05 * delta

	if owner.modulate.a <= .1:
		owner.call_deferred("queue_free")

func _on_animation_started(anim : String) -> void:
	EventBus.emit_signal("play_sound_random", DeathSounds, owner.global_position)

func _on_animation_finished(anim : String) -> void:
	if !Global.GameOptions.graphics.corpses_decay:
		owner.set_process(false)

	owner.set_physics_process(false)
