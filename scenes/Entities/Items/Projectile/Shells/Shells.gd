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

	$Projectile.linear_velocity.y = $Projectile.linear_velocity.rotated(-.08).y
	$Projectile3.linear_velocity.y = $Projectile3.linear_velocity.rotated(.08).y
