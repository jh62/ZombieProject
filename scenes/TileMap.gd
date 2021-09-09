extends TileMap

func _ready():
	pass
	
func _on_mob_spawned(mob : Mobile) -> void:
	area_connect_to_mob(mob)

func area_connect_to_mob(mob) -> void:
	for area in get_children():
		mob.connect("on_footstep", area, "_on_mob_footstep")
