extends Sprite

var current_item : BaseItem
var action := false
var action_duration := 0.0
var action_elapsed := 0.0

func _ready() -> void:
	pass

func set_item(item : BaseItem) -> void:
	current_item = item

func set_animation(state) -> void:
	if state == "action":
		if action:
			return
		else:
			action = true
			action_duration = .4
			action_elapsed = 0.0

	yield(get_tree().create_timer(.02),"timeout")
	texture = current_item.get_texture(state)

func update_frame(frame : int, hframes : int, vframes : int, flip_h : bool) -> void:
	self.frame = frame
	self.hframes = hframes
	self.vframes = vframes
	self.flip_h = flip_h

	if action:
		action_elapsed += get_process_delta_time()
		if action_elapsed > action_duration:
			action = false
			set_animation("idle")
