extends KinematicBody2D

onready var sprite := $Sprite
onready var sprite_arms := $SpriteArms
onready var anim := $AnimationPlayer

onready var weapon := preload("res://scenes/Weapon/Handgun.tscn").instance()

var dir := Vector2.ZERO
var facing := Vector2.ZERO
var speed := 60.0

func _ready() -> void:
	add_child(weapon)

func _process(delta: float) -> void:
	weapon.update_frame(sprite.frame, sprite.hframes, sprite.vframes, sprite.flip_h)
	_process_input()

	if dir.length() != 0:
		var vel := dir * speed
		move_and_slide(vel)

func _process_input() -> void:
	var look_at_dir := global_position.direction_to(get_global_mouse_position()).round()
	var input_x := int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	var input_y := int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	dir.x = input_x
	dir.y = input_y

	if look_at_dir.x != 0:
		facing.x = look_at_dir.x
		if look_at_dir.y == 0:
			facing.y = 0

	if look_at_dir.y != 0:
		if look_at_dir.x == 0:
			facing.x = 0
		facing.y = look_at_dir.y

	var anim_data := ""

	if facing.y < 0:
		anim_data += "n"
	elif facing.y > 0:
		anim_data += "s"

	if facing.x != 0:
		anim_data += "e"

	sprite.flip_h = true if facing.x < 0 else false
	sprite_arms.flip_h = true if facing.x < 0 else false

	if anim_data.empty():
		anim_data = "e"

	var anim_name := "idle" if dir.length() == 0 else "run"

	if anim.current_animation != (anim_name + "_disarmed_" + anim_data):
		var backwards := (facing-dir).length() > 1.4 && facing != dir
		#fixes weird glitch when changing textures
		call_deferred("_set_animations", anim_name, anim_data, sprite.hframes, sprite.vframes, backwards)

func _set_animations(anim_name, anim_data, hframes, vframes, backwards := false) -> void:
	if backwards:
		anim.play_backwards(anim_name + "_disarmed_" + anim_data)
	else:
		anim.play(anim_name + "_disarmed_" + anim_data)

	weapon.set_animation(anim_name, anim_data, sprite.hframes, sprite.vframes)


func _on_AnimationPlayer_animation_started(anim_name: String) -> void:
	match anim_name.split("_")[0]:
		"idle":
			sprite_arms.texture = load("res://assets/res/char/arms/idle_disarmed.tres")
		"run":
			sprite_arms.texture = load("res://assets/res/char/arms/run_disarmed.tres")
