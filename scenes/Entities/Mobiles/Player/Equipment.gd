extends Node2D

export var item : PackedScene

func _ready() -> void:
	if item != null:
		var t = item.instance()
		equip(t)		

func equip(item : BaseItem) -> void:
	if get_child_count() > 0:
		var child : BaseItem = get_child(0)
		child.queue_free()
		
	item.equipper = self.owner	
	visible = true
	add_child(item)

func _process(delta: float) -> void:
	pass
