extends Control

onready var player : Player
onready var bike : Bike

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
onready var n_Minimap := $Minimap

func _ready():
	pass

func initialize(_player, _bike) -> void:
	player = _player
	bike = _bike

	player.connect("on_hit", self, "_on_player_hit")
	player.connect("on_item_pickedup", self, "_on_item_pickedup")
	player.connect("on_loot_pickedup", self, "_on_player_loot")
	player.connect("on_footstep", self, "_on_player_footstep")
	bike.connect("on_fuel_changed", self, "_on_bike_fuel_changed")

	EventBus.connect("on_player_death", self, "_on_player_death")
	EventBus.connect("on_weapon_reloaded", self, "update_weapon_status")
	EventBus.connect("on_request_update_health", self, "update_healthbar")
	EventBus.connect("fuel_pickedup", self, "_on_fuelcan_pickup")
	EventBus.connect("fuel_changed", self, "_on_fuelcan_changed")
	EventBus.connect("fuel_emptied", self, "_on_fuel_emptied")
	EventBus.connect("on_weapon_fired", self, "_on_weapon_fired")
	EventBus.connect("update_objective", self, "_update_objective")

	n_Minimap.player = player

	n_GasTankProgressBar.max_value = Globals.MAX_FUEL_LITERS
	n_HealthBar.max_value = player.max_hitpoints
	n_FuelCan.visible = false

	update_healthbar()
	update_weapon_status()
	update_fuel_status()
	update_loot_count()

func _process(delta):
	$Panel.visible = Input.is_action_pressed("objectives")

func update_healthbar() -> void:
	n_HealthBar.value = player.hitpoints

func _on_player_hit() -> void:
	update_healthbar()

func _on_player_death(player) -> void:
	visible = false

func update_loot_count() -> void:
	yield(get_tree().create_timer(.1),"timeout") # so it updates properly
	n_LabelLootCount.text = "x {0}".format({0:PlayerStatus.loot_count})

func update_weapon_status(_weapon_type := -1) -> void:
	yield(get_tree().create_timer(.1),"timeout") # so it updates properly
	var weapon = player.equipment.get_item()

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
	n_GasTankProgressBar.value = bike.fuel_amount
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

func _on_bike_fuel_changed(_amount):
	update_fuel_status()

func _on_weapon_fired(_position ) -> void:
	update_weapon_status()

func is_objective_completed(idx) -> bool:
	var objective_idx = clamp(idx, 0, $Panel/VBoxContainer.get_child_count())
	var n_Objective := $Panel/VBoxContainer.get_child(objective_idx)
	
	return n_Objective.get_node("CheckBox").pressed
	
func _update_objective(idx, completed, hint := true, text := "", delay := 0.5) -> void:
	yield(get_tree().create_timer(delay), "timeout")
	
	var objective_idx = clamp(idx, 0, $Panel/VBoxContainer.get_child_count())
	var n_Objective := $Panel/VBoxContainer.get_child(objective_idx)
	n_Objective.visible = true
	n_Objective.get_node("CheckBox").pressed = completed
	
	if !text.empty():
		n_Objective.get_node("Label").text = text
		
	if hint:
		$AnimationPlayer.play("update_obj")
