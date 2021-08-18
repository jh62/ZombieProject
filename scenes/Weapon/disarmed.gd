extends Weapon

const texture_idle := preload("res://assets/res/char/arms/idle_disarmed.tres")
const texture_run := preload("res://assets/res/char/arms/run_disarmed.tres")

func _ready() -> void:
	pass

func set_animation(anim_name, anim_dir, hframes, vframes) -> void:
	$Sprite.hframes = hframes
	$Sprite.vframes = vframes
	yield(get_tree().create_timer(.02),"timeout")
	print_debug("a")
	match anim_name:
		"idle":
			$Sprite.texture = texture_idle
		"run":
			$Sprite.texture = texture_run

func update_frame(frame, hframes, vframes, flip_h := false) -> void:
	$Sprite.frame = frame
	$Sprite.hframes = hframes
	$Sprite.vframes = vframes
	$Sprite.flip_h = flip_h
