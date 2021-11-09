class_name Pickable extends Area2D

export var pick_delay := 1.15

func _ready():
	print_debug("ready")

	$CollisionShape2D.disabled = true
	yield(get_tree().create_timer(pick_delay),"timeout")
	$CollisionShape2D.disabled = false

# virtual methods
func _on_Pickable_body_entered(body: Node) -> void:
	pass
