tool
extends StaticObject

export var object_id := 0 setget set_object_id

func _ready():
	pass

func set_object_id(_object_id) -> void:
	object_id = _object_id

	for i in $Sprites.get_child_count():
		var sprite = $Sprites.get_child(i)
		sprite.visible = i == object_id
