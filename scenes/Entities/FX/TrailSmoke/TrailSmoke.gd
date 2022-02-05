class_name TrailSmoke extends Particles2D

var p : Node2D

func _ready():
	var _parent := get_parent()

	if !(_parent is StaticObject):
		return

	p = _parent
#	var k := p.max_hitpoints * .8
#	amount = clamp(k / p.hitpoints, 1, 8)
	if p.hitpoints <= (p.max_hitpoints * .1):
		modulate = Color8(60,60,60)
	elif  p.hitpoints <= (p.max_hitpoints * .25):
		modulate = Color.darkgray

func _process(delta):
	if p == null || p.hitpoints <= 0:
		call_deferred("queue_free")
		return

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	emitting = false

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	emitting = true
