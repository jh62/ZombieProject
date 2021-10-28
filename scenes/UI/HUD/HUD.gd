extends Control

export var p_player : NodePath
export var p_bike : NodePath

onready var n_player : Player = get_node(p_player)
onready var n_bike : Bike = get_node(p_bike)
onready var health_bar := $CharStats/HBoxContainer/HealthBar
onready var loot_count := $CharStats/HBoxContainer/VBoxContainer/LootBag/HBoxContainer/Label
onready var gas_tank := $GasTank/ProgressBar
onready var gas_tank_fill_amount := $GasTank/Label
onready var weapon_ammo := $CharStats/HBoxContainer/VBoxContainer/Gun/VBoxContainer/HBoxContainer/Label

func _ready():
#	print_debug($CharStats/HBoxContainer/VBoxContainer/LootBag/HBoxContainer/TextureRect.rect_global_position)
	n_player.connect("on_hit", self, "_on_player_hit")
	n_player.connect("on_item_pickedup", self, "_on_item_pickedup")
	n_player.connect("on_loot_pickedup", self, "_on_player_loot")
	n_bike.connect("on_fuel_changed", self, "_on_bike_fuel_changed")

	health_bar.max_value = n_player.max_hitpoints
	gas_tank.max_value = Globals.MAX_FUEL_LITERS

	update_healthbar()
	update_weapon_status()
	update_fuel_status()

func update_healthbar() -> void:
	health_bar.value = n_player.max_hitpoints - n_player.hitpoints

func _on_player_hit() -> void:
	update_healthbar()

func update_loot_count() -> void:
	yield(get_tree(),"idle_frame") # so it updates properly
	loot_count.text = "x{0}".format({0:n_player.loot_count})

func update_weapon_status() -> void:
	yield(get_tree(),"idle_frame") # so it updates properly
	var weapon = n_player.equipment.get_item()

	if weapon != null:
		if!weapon.is_connected("on_use", self, "_on_equipment_use"):
			weapon.connect("on_use", self, "_on_equipment_use")

	var mag_left := max(weapon.bullets / weapon.mag_size - 1, 0)

	weapon_ammo.visible = weapon.bullets + weapon.magazine > 0
	weapon_ammo.text = "x{0}".format({0:mag_left})

func update_fuel_status() -> void:
	gas_tank.value = n_bike.fuel_amount
	gas_tank_fill_amount.text = "{0}%".format({0:(gas_tank.value / gas_tank.max_value) * 100})

func _on_item_pickedup() -> void:
	update_weapon_status()

func _on_player_loot() -> void:
	update_loot_count()

func _on_equipment_use() -> void:
	update_weapon_status()

func _on_bike_fuel_changed(amount):
	update_fuel_status()
