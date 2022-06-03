class_name Building extends StaticObject

func _ready():
	material_type = MaterialType.CEMENT
	
	for child in $Sprite.get_children():
		if !(child is LightOccluder2D):
			continue
			
		child.visible = true
