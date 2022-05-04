extends Sprite

func _ready():
	frame = randi() % (hframes * vframes)
