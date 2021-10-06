class_name Bike extends KinematicBody2D

signal on_fuel_changed(amount)

var fuel_amount := 0.0

func _ready():
	$Area2D/CollisionShape2D.shape = $CollisionShape2D.shape

func _on_body_entered(body):
	pass # Replace with function body.
