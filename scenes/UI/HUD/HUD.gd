extends Control

export var p_player : NodePath
export var p_bike : NodePath

onready var n_player : Player = get_node(p_player)
onready var n_bike : Bike = get_node(p_bike)
onready var n_Stats := $CharStats
onready var n_HealthBar := $CharStats/HBoxContainer/HealthTextureProgress
onready var n_LootbagTexture := $LootBag/MarginContainer/HBoxContainer/TextureRect
onready var n_LabelLootCount := $LootBag/MarginContainer/HBoxContainer/Label
onready var n_GasTank := $GasTank
onready var n_GasTankProgressBar := $GasTank/ProgressBar
onready var n_GasTankLabel := $GasTank/Label
onready var n_WeaponIcon := $Gun/VBoxContainer/VBoxContainer/TextureRect
onready var n_AmmoRoot := $Gun/VBoxContainer/VBoxContainer/HBoxContainer
onready var n_AmmoIcon := $Gun/VBoxContainer/VBoxContainer/HBoxContainer/TextureRect
onready var n_AmmoLabel := $Gun/VBoxContainer/VBoxContainer/HBoxContainer/Label
onready var n_Tween := $Tween

func _ready():
	n_player.connect("on_hit", self, "_on_player_hit")
	n_player.connect("on_item_pickedup", self, "_on_item_pickedup")
	n_player.connect("on_loot_pickedup", self, "_on_player_loot")
	n_player.connect("on_footstep", self, "_on_player_footstep")
	n_bike.connect("on_fuel_changed", self, "_on_bike_fuel_changed")

	n_GasTankProgressBar.max_value = Globals.MAX_FUEL_LITERS
	n_HealthBar.max_value = n_player.max_hitpoints

	update_healthbar()
	update_weapon_status()
	update_fuel_status()
	update_loot_count()

func update_healthbar() -> void:
	n_HealthBar.value = n_player.hitpoints

func _on_player_hit() -> void:
	update_healthbar()

func update_loot_count() -> void:
	yield(get_tree().create_timer(.1),"timeout") # so it updates properly
	n_LabelLootCount.text = "x {0}".format({0:n_player.loot_count})

func update_weapon_status() -> void:
	yield(get_tree().create_timer(.1),"timeout") # so it updates properly
	var weapon = n_player.equipment.get_item()

	if weapon != null:
		if!weapon.is_connected("on_use", self, "_on_equipment_use"):
			weapon.connect("on_use", self, "_on_equipment_use")

	n_WeaponIcon.texture = weapon.get_icon()

	n_AmmoRoot.visible = weapon is Firearm

	if n_AmmoRoot.visible:
#		var mag_left := ceil(float(weapon.bullets) / float(weapon.mag_size))
		var mag_left = weapon.bullets / weapon.mag_size
		n_AmmoIcon.texture = weapon.get_mag_icon()
		n_AmmoLabel.text = "x {0}".format({0:mag_left})

func update_fuel_status() -> void:
	n_GasTankProgressBar.value = n_bike.fuel_amount
	n_GasTankLabel.text = "{0}%".format({0:str(n_GasTankProgressBar.value / n_GasTankProgressBar.max_value * 100).pad_decimals(0)})

var alpha_when_behind := .05

func _on_player_footstep(mob) -> void:
	var behind_stats = n_Stats.get_rect().has_point(mob.get_global_transform_with_canvas().origin)
	n_Stats.modulate.a = alpha_when_behind if behind_stats else 1.0

	var behind_gas_tank = n_GasTank.get_rect().has_point(mob.get_global_transform_with_canvas().origin)
	n_GasTank.modulate.a = alpha_when_behind if behind_gas_tank else 1.0

func _on_item_pickedup() -> void:
	update_weapon_status()

func _on_player_loot() -> void:
	update_loot_count()

	if !n_Tween.is_active():
		n_Tween.interpolate_property(n_LootbagTexture,"rect_scale",Vector2(1,1),Vector2(1.1,1.1), .1,n_Tween.TRANS_BOUNCE,n_Tween.EASE_OUT_IN)
		n_Tween.start()
		yield(n_Tween,"tween_completed")
		n_Tween.interpolate_property(n_LootbagTexture,"rect_scale",n_LootbagTexture.rect_scale,Vector2(1,1), .1,n_Tween.TRANS_BOUNCE,n_Tween.EASE_OUT_IN)
		n_Tween.start()

func _on_equipment_use() -> void:
	update_weapon_status()

func _on_bike_fuel_changed(amount):
	update_fuel_status()
