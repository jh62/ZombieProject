extends Control

export var p_player : NodePath
export var p_bike : NodePath
export var p_tilemap : NodePath

onready var n_player : Player = get_node(p_player)
onready var n_bike : Bike = get_node(p_bike)
onready var n_Stats := $CharStats
onready var n_HealthBar := $CharStats/HBoxContainer/HealthTextureProgress
onready var n_LootbagTexture := $LootBag/MarginContainer/HBoxContainer/TextureRect
onready var n_LabelLootCount := $LootBag/MarginContainer/HBoxContainer/Label
onready var n_GasTank := $GasTank
onready var n_GasTankProgressBar := n_GasTank.get_node("ProgressBar")
onready var n_GasTankLabel := n_GasTank.get_node("Label")
onready var n_WeaponIcon := $Gun/VBoxContainer/VBoxContainer/TextureRect
onready var n_AmmoRoot := $Gun/VBoxContainer/VBoxContainer/HBoxContainer
onready var n_AmmoIcon := $Gun/VBoxContainer/VBoxContainer/HBoxContainer/TextureRect
onready var n_AmmoLabel := $Gun/VBoxContainer/VBoxContainer/HBoxContainer/Label
onready var n_FuelCan := $CharStats/HBoxContainer/MarginContainer/VBoxContainer/TextureProgressFuelCan
onready var n_Tween := $Tween
onready var n_Camera := $ViewportContainer/Viewport/Camera2D
onready var n_Minimap := $Minimap

func _ready():
	n_player.connect("on_hit", self, "_on_player_hit")
	n_player.connect("on_item_pickedup", self, "_on_item_pickedup")
	n_player.connect("on_loot_pickedup", self, "_on_player_loot")
	n_player.connect("on_footstep", self, "_on_player_footstep")
	n_bike.connect("on_fuel_changed", self, "_on_bike_fuel_changed")

	EventBus.connect("on_weapon_reloaded", self, "update_weapon_status")
	EventBus.connect("on_request_update_health", self, "update_healthbar")
	EventBus.connect("fuel_pickedup", self, "_on_fuelcan_pickup")
	EventBus.connect("fuel_changed", self, "_on_fuelcan_changed")
	EventBus.connect("fuel_emptied", self, "_on_fuel_emptied")
	EventBus.connect("on_weapon_fired", self, "_on_weapon_fired")

	n_Minimap.n_player = n_player

	n_GasTankProgressBar.max_value = Globals.MAX_FUEL_LITERS
	n_HealthBar.max_value = n_player.max_hitpoints
	n_FuelCan.visible = false

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

	n_WeaponIcon.texture = weapon.get_icon()

	n_AmmoRoot.visible = weapon is Firearm

	if n_AmmoRoot.visible:
		var mag_left

		if Global.GameOptions.gameplay.discard_bullets:
			mag_left = ceil(float(weapon.bullets) / float(weapon.mag_size))
		else:
			mag_left = weapon.bullets

		if weapon.magazine > 0:
			$AnimationPlayer.play("RESET")
		else:
			$AnimationPlayer.play("gun_flash")

		n_AmmoIcon.texture = weapon.get_mag_icon()
		n_AmmoLabel.text = "x {0}".format({0:mag_left})
	else:
		$AnimationPlayer.play("RESET")

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

func _on_fuelcan_pickup(amount) -> void:
	n_FuelCan.max_value = Global.MAX_FUEL_LITERS
	n_FuelCan.step = Bike.STEP
	n_FuelCan.value = amount
	n_FuelCan.visible = true

func _on_fuelcan_changed(amount) -> void:
	n_FuelCan.value = amount

func _on_fuel_emptied() -> void:
	n_FuelCan.visible = false

func _on_player_loot() -> void:
	update_loot_count()

	if !n_Tween.is_active():
		n_Tween.interpolate_property(n_LootbagTexture,"rect_scale",Vector2(1,1),Vector2(1.1,1.1), .1,n_Tween.TRANS_BOUNCE,n_Tween.EASE_OUT_IN)
		n_Tween.start()
		yield(n_Tween,"tween_completed")
		n_Tween.interpolate_property(n_LootbagTexture,"rect_scale",n_LootbagTexture.rect_scale,Vector2(1,1), .1,n_Tween.TRANS_BOUNCE,n_Tween.EASE_OUT_IN)
		n_Tween.start()

func _on_bike_fuel_changed(amount):
	update_fuel_status()

func _on_weapon_fired() -> void:
	update_weapon_status()

func _on_Entities_on_mob_spawned(mob):
	n_Minimap._on_mob_spawned(mob)
