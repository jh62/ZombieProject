class_name MeleeWeapon extends BaseWeapon

var Sounds := {
	MeleeType.EDGED:{
		"swing" : [
			preload("res://assets/sfx/weapons/melee_swing_01.wav"),
			preload("res://assets/sfx/weapons/melee_swing_02.wav"),
		],
		"hit": [
			preload("res://assets/sfx/impact/melee/blade_hit_1.wav"),
			preload("res://assets/sfx/impact/melee/blade_hit_2.wav"),
			preload("res://assets/sfx/impact/melee/blade_hit_3.wav")
		],
		"pickup":[
			preload("res://assets/sfx/weapons/blade_pickup.wav")
		]
	},
	MeleeType.BLUNT:{
		"swing" : [
			preload("res://assets/sfx/weapons/melee_swing_01.wav"),
			preload("res://assets/sfx/weapons/melee_swing_02.wav"),
		],
		"hit": [
			preload("res://assets/sfx/impact/melee/blunt_hit_1.wav"),
			preload("res://assets/sfx/impact/melee/blunt_hit_2.wav"),
			preload("res://assets/sfx/impact/melee/blunt_hit_3.wav")
		],
		"pickup":[
			preload("res://assets/sfx/weapons/blunt_pickup.wav")
		]
	},
}

const ANIMATIONS := {
	"idle": null,
	"run": null,
	"shoot": null
}

enum MeleeType {
	EDGED,
	BLUNT
}

export(MeleeType) var melee_type := MeleeType.EDGED
export var swing_time := 0.25

onready var raycast := $RayCast

# Virtual methods
func get_swing_sound():
	return Sounds.get(melee_type).swing

func get_sound_shoot():
	return Sounds.get(melee_type).hit

func get_pickup_sound():
	return Sounds.get(melee_type).pickup

func _ready() -> void:
	EventBus.emit_signal("play_sound_random", get_pickup_sound(), global_position)

func _on_action_pressed(action_type, facing) -> void:
	match action_type:
		EventBus.ActionEvent.USE:
			in_use = true
		EventBus.ActionEvent.RELOAD:
			return

func _on_action_released(action_type : int, facing) -> void:
	if in_use:
		yield(anim_p,"animation_finished")
	in_use = false

func set_bullets(val : int) -> void:
	pass

func set_magazine(val : int):
	pass

func _process(delta):
	pass

func update_animations() -> void:
	if equipper == null:
		return

	var state = equipper.fsm.current_state
	var facing = equipper.facing

	var state_name =  state.get_name()
	var facing_name = Mobile.get_facing_as_string(facing)
	var anim_name = "{0}_{1}".format({0:state_name,1:facing_name})

	if !anim_p.has_animation(anim_name):
		return

	flip_h = facing.x < 0

	if in_use:
		if anim_p.current_animation.begins_with("shoot"):
			return
		anim_name = "shoot_{0}".format({0:facing_name})
		anim_p.playback_speed = fire_rate
	else:
		anim_p.playback_speed = 1.0

	anim_p.play(anim_name)

func raycast_enable(enable) -> void:
	for ray in raycast.get_children():
		ray.enabled = enable
		ray.force_raycast_update()

func _on_action_animation_started(anim_name, facing) -> void:
	texture = ANIMATIONS.get(anim_name)

	get_parent().set("show_behind_parent", facing == "n")

	match anim_name:
		"shoot":
			equipper.can_move = false
			equipper.vel = Vector2.ZERO
			equipper.dir = Vector2.ZERO
#			equipper.vel += -equipper.facing * damage * 5

			match facing:
				"n":
					raycast.rotation_degrees = -45
				"ne":
					raycast.rotation_degrees = 0 if !flip_h else -90
				"e":
					raycast.rotation_degrees = 45 if !flip_h else -135
				"se":
					raycast.rotation_degrees = 90 if !flip_h else 180
				"s":
					raycast.rotation_degrees = 135

			var snd = get_swing_sound()
			emit_signal("on_use")

			EventBus.emit_signal("play_sound_random", snd, global_position)
			
			if !$AreaAttack.get_overlapping_bodies().empty():
				var _target = $AreaAttack.get_overlapping_bodies()[0]
				var can_see_target = equipper.check_LOS(_target)
				
				if can_see_target:					
					_target.on_hit_by(self)

#			raycast_enable(true)
#			yield(get_tree().create_timer(.05),"timeout")
#			if in_use:
#				for ray in raycast.get_children():
#					ray = ray as RayCast2D
#					if ray.is_colliding():
#						var collider = ray.get_collider()
#						if collider.is_alive() && !collider.fsm.current_state.get_name().begins_with("hit"):
#							EventBus.emit_signal("play_sound_random", get_sound_shoot(), collider.global_position)
#							collider.on_hit_by(self)
#							EventBus.emit_signal("create_shake", 0.3, knockback * 2, knockback, 0)

func _on_action_animation_finished(anim_name, facing) -> void:
	match anim_name:
		"shoot":
			equipper.can_move = true
			equipper.busy_time += swing_time
			in_use = false
			raycast_enable(false)
