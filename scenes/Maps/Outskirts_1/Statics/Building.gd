class_name Building extends StaticObject

func _ready():
	material_type = MaterialType.CEMENT
	$Sprite.normal_map = preload("res://assets/maps/map_test_n.png")
