class_name Pickable extends Area2D


func _ready() -> void:
	pass

func _on_Pickable_body_entered(body: Node) -> void:
	print_debug("Not implemented")
	queue_free()
