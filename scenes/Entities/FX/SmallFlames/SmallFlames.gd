extends Area2D

var speed := 2.0
var dir := Vector2(1,1)
var lifetime := 50.0
var elapsed := 0.0
var damage := .66

func _ready():
	add_to_group(Globals.GROUP_FIRE)

func _process(delta):
	elapsed += delta

	if speed == 0.0:
		if elapsed >= lifetime:
			$Light2D.energy -= .0005
			$AnimatedSprite.scale.y -= .0035
			$AudioStreamPlayer2D.volume_db -= 0.1

		if $AnimatedSprite.scale.y < 0.0:
			call_deferred("queue_free")

		return

	global_position = global_position.linear_interpolate(global_position + (dir * speed), 1.0)

	speed *= .9

	if is_zero_approx(speed):
		speed = 0.0

func _on_SmallFlames_body_entered(body : Node2D):
	if body.is_in_group(Globals.GROUP_HOSTILES):
		if !body.find_node("Fire", true, false):
			var Fire := preload("res://scenes/Entities/FX/Fire/Fire.tscn")
			body.add_child(Fire.instance())
			call_deferred("queue_free")
	elif body.is_in_group(Globals.GROUP_FUELCAN):
		body.explode()
	else:
		body.on_hit_by(self)
