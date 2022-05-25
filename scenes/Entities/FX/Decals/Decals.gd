extends AnimatedSprite

func _ready():
	var anims := frames.get_animation_names()
	var anim_idx := randi() % anims.size()
	play(anims[anim_idx])
