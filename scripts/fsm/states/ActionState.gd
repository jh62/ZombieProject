class_name ActionState extends State

var elapsed : float
var duration : float

func get_name():
	return "action"

func update(owner : Mobile, delta) -> void:
	elapsed += delta
	if elapsed > duration:
		print_debug("attacked stopped")
