extends Control

export var player : NodePath

onready var m_player : Player = get_node(player)

func _ready():
	m_player.connect("on_hit", self, "_on_player_hit")
	m_player.connect("on_item_pickedup", self, "_on_item_pickedup")
	m_player.connect("on_loot_pickedup", self, "_on_player_loot")	
	
	update_healthbar()
	update_weapon_status()

func update_healthbar() -> void:
	$HealthBar.value = m_player.max_hitpoints - m_player.hitpoints

func _on_player_hit() -> void:
	update_healthbar()

func update_loot_count() -> void:
	$LootBag/HBoxContainer/Label.text = "x {0}".format({0:m_player.loot_count})

func update_weapon_status() -> void:
	var weapon = m_player.equipment.get_item()
	
	if weapon != null:
		if!weapon.is_connected("on_use", self, "_on_equipment_use"):
			weapon.connect("on_use", self, "_on_equipment_use")
			
	var mag_left := round(weapon.bullets / weapon.mag_size)
	
	$Gun/VBoxContainer/MarginContainer/Label.visible = weapon.bullets > 0
	$Gun/VBoxContainer/MarginContainer/Label.text = str(mag_left)

func _on_item_pickedup() -> void:
	yield(get_tree(),"idle_frame") # so it updates properly
	update_weapon_status()
	
func _on_player_loot() -> void:
	update_loot_count()

func _on_equipment_use() -> void:
	update_weapon_status()
