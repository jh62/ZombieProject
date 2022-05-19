extends StaticObject

func _ready():
	$Sprite.frame = randi() % ($Sprite.hframes * $Sprite.vframes)
