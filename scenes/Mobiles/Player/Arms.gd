extends Sprite

var current_item : BaseItem

func _ready() -> void:
	pass

func set_item(item : BaseItem) -> void:
	current_item = item

func set_animation(state : State) -> void:
	yield(get_tree().create_timer(.02),"timeout")
	texture = current_item.get_texture(state)

func update_frame(frame : int, hframes : int, vframes : int, flip_h : bool) -> void:
	self.frame = frame
	self.hframes = hframes
	self.vframes = vframes
	self.flip_h = flip_h
