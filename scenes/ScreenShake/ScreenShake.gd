extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var priority = 0

onready var camera = get_parent()

func _ready():
	EventBus.connect("on_fuelcan_explode", self, "_on_fuelcan_explode")
	EventBus.connect("create_shake", self, "_on_create_shake")

func _on_create_shake(duration, frequency, amplitude, priority) -> void:
	start(duration, frequency, amplitude, priority)

func start(duration = 0.2, frequency = 15, amplitude = 16, priority = 0):
	if (priority >= self.priority):
		self.priority = priority
		self.amplitude = amplitude

		$Duration.wait_time = duration
		$Frequency.wait_time = 1 / float(frequency)
		$Duration.start()
		$Frequency.start()

		_new_shake()

func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)

	$ShakeTween.interpolate_property(camera, "offset", camera.offset, rand, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

func _reset():
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

	priority = 0

func _on_Frequency_timeout():
	_new_shake()

func _on_Duration_timeout():
	$Frequency.stop()
	$Duration.stop()

func _on_Player_on_hit():
	start(0.1, 15, 4, 0)

func _on_fuelcan_explode(position):
	start(0.25, 12, 8, 0)

func _on_ShakeTween_tween_completed(object, key):
	pass
