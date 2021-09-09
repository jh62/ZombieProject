extends CanvasLayer

const materials := [
	preload("res://assets/res/material/BulletTrail.tres")
]

func _ready():
	for material in materials:
		var particle := Particles2D.new()
		particle.set_process_material(material)
		particle.set_one_shot(true)
		particle.set_emitting(true)
		self.add_child(particle)
	yield(get_tree().create_timer(.25),"timeout")
	set_process(false)
	set_physics_process(false)
