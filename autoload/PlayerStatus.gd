extends Node

var current_level := 1 setget set_current_level
var weapons := {}
var perks := {}
var death_count := 0
var loot_count := 0
var precision_margin_error := 0.15
var max_hitpoints := 10

func set_current_level(_val) -> void:
	current_level = clamp(_val, 1, 4)
