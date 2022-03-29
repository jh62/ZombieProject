extends Node2D

var linear_velocity
var damage
var knockback

func _ready():
	for shells in get_children():
		var shell := shells as Projectile
		shell.linear_velocity = linear_velocity
		shell.damage = damage
		shell.knockback = knockback

	$Projectile.linear_velocity = $Projectile.linear_velocity.rotated(-.12)
	$Projectile3.linear_velocity = $Projectile3.linear_velocity.rotated(.12)
