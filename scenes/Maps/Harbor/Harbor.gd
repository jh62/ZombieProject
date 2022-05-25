extends Map

onready var n_AreaExplosives := $Triggers/AreaExplosives
onready var n_Player := get_node("TileMap2/Entities/Mobs/Player")

const Objectives := {
	0: [0, "Get to the ship"],
	1: [0, "Blow up the blockade"],
	2: [0, "Find the key to open the gate"],
	3: [0, ""],
}

func _ready():
	n_Player.connect("on_search_start", self, "_on_player_item_use")
	
	yield(get_tree().create_timer(0.5),"timeout")
	EventBus.emit_signal("update_objective", 0, false, false, Objectives.get(0)[1])

func _spawn_fuelcans() -> void:
	var FuelCan := preload("res://scenes/Entities/Items/FuelCan/FuelCan.tscn")
	var _fuel_remaning := Global.MAX_FUEL_LITERS
	var _max_fuelcans := max_fuelcans
	
	var spawn_zones := n_SpawnAreasFuel.get_children()
	spawn_zones.shuffle()
	
	for zone in spawn_zones:
		var fuelcan := FuelCan.instance()
		var fuel_amount := float(Global.MAX_FUEL_LITERS / _max_fuelcans)
		_fuel_remaning = max(0.0, _fuel_remaning - fuel_amount)
		n_Entities.add_child(fuelcan)
		fuelcan.global_position = zone.global_position
		fuelcan.fuel_amount = fuel_amount + rand_range(0.11, 0.73)
		fuelcan.can_stack = false
		
		if _fuel_remaning == 0.0:
			return
	
func _on_player_item_use(mob : Node2D) -> void:
	if mob in n_AreaExplosives.get_overlapping_bodies():
		n_AreaExplosives.on_activation(mob)
		return

func _on_objective_completed(objective_id, _step):	
	match objective_id:
		0:
			if _step >= 1:
				EventBus.emit_signal("update_objective", 0, false, true, "Get in the ship")
			else:
				EventBus.emit_signal("update_objective", 0, false, true, "Blow up the blockade")
			
		1:
			if _step >= 2:
				EventBus.emit_signal("update_objective", 1, true, true)
			elif _step >= 1:
				EventBus.emit_signal("update_objective", 1, false, true, "Open the harbor gate with the key")
			else:
				EventBus.emit_signal("update_objective", 1, false, true, "Find the key to open the gate")
		3:			
			EventBus.emit_signal("update_objective", 0, true, false)
			EventBus.emit_signal("update_objective", 1, false, true, "Escape on ship")

func _on_FenceGate2_on_door_used(position, tiles_blocked):
	_on_objective_completed(1, 2)
	$TileMap2/Entities/Statics/FenceGate2.disconnect("on_door_used", self, "_on_FenceGate2_on_door_used")
