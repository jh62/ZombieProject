class_name Player extends Mobile

export var player_id := 1

signal on_search_start(this)
signal on_search_end(this)
signal on_aiming_start(this)
signal on_aiming_stop(this)
signal on_busy_time_added(time)

signal on_death
signal on_hit
signal on_item_pickedup
signal on_loot_pickedup

var states := {}

onready var equipment := $Equipment
onready var vision := $Vision
onready var ray := $RayHeadshot
onready var camera := $Camera2D
onready var crosshair := $Crosshair

var aiming = false
var busy_time := 0.0 setget set_busy_time

func _ready() -> void:
	add_to_group(Global.GROUP_PLAYER)
	
	EventBus.connect("on_item_pickedup", self, "_on_item_pickedup")
	EventBus.connect("on_loot_pickedup", self, "_on_loot_pickedup")
	EventBus.connect("on_unpause", self, "_on_unpaused")
	
	states = {
		"idle": preload("res://scripts/fsm/states/IdleState.gd").new(self),
		"run": preload("res://scripts/fsm/states/RunState.gd").new(self),
		"die": preload("res://scripts/fsm/states/DieState.gd").new(self),
		"hit": preload("res://scripts/fsm/states/HitState.gd").new(self),
		"search": preload("res://scripts/fsm/states/SearchState.gd").new(self)
	}
	fsm.current_state = states.idle

	self.max_hitpoints = PlayerStatus.max_hitpoints
	self.hitpoints = max_hitpoints
	
	yield(get_tree().create_timer(.5),"timeout") # fix!!
	var _p_equipment = get_equipment()
	_p_equipment.set_primary_item(PlayerStatus.get_weapon(0))
	_p_equipment.set_secondary_item(PlayerStatus.get_weapon(1))
	_p_equipment.equip_primary()

func _process_animations() -> void:
	._process_animations()

	Global.set_canvas_item_light_mask_value(sprite, 5, facing.y >= 0)

	match facing.round():
		Vector2(0,-1):
			$Flashlight.rotation_degrees = -90
			vision.rotation_degrees = -90
		Vector2(0,1):
			$Flashlight.rotation_degrees = 90
			vision.rotation_degrees = 90
		Vector2(1,0):
			$Flashlight.rotation_degrees = 0
			vision.rotation_degrees = 0
		Vector2(1,1):
			$Flashlight.rotation_degrees = 45
			vision.rotation_degrees = 45
		Vector2(1,-1):
			$Flashlight.rotation_degrees = -45
			vision.rotation_degrees = -45
		Vector2(-1,0):
			$Flashlight.rotation_degrees = 180
			vision.rotation_degrees = 180
		Vector2(-1,-1):
			$Flashlight.rotation_degrees = -135
			vision.rotation_degrees = -135
		Vector2(-1,1):
			$Flashlight.rotation_degrees = 135
			vision.rotation_degrees = 135
		_:
			$Flashlight.rotation_degrees = 0
			vision.rotation_degrees = 0

func _process(delta: float) -> void:
	._process(delta)

	var slowdown : float
	
	if PlayerStatus.has_perk(Perk.PERK_TYPE.FAST_RELOAD):
		slowdown = 1.0
	else:
		slowdown = 0.25 if (dir.length() != 0) else 1.0
	
	busy_time = max(busy_time - delta * slowdown, 0.0)

	if is_alive():
		if can_move:
			_process_input()

func _on_unpaused() -> void:
	emit_signal("on_aiming_stop", self)
	emit_signal("on_search_end", self)
	EventBus.emit_signal("action_released", EventBus.ActionEvent.USE, facing)

func _unhandled_input(event: InputEvent) -> void:
	if Global.GameOptions.gameplay.joypad:
		if event is InputEventMouse:
			return
	
	if get_tree().paused:
		return

	if busy_time > 0:
		return
		
	if can_move:
		if event.is_action_pressed("action"):
			EventBus.emit_signal("action_pressed", EventBus.ActionEvent.USE, facing)
			return
		elif event.is_action_released("action"):
			EventBus.emit_signal("action_released", EventBus.ActionEvent.USE, facing)
			return

		if event.is_action_pressed("reload") && !Input.is_action_pressed("action"):
			var equipped = get_equipped()

			if equipped && equipped is Firearm:
				aiming = false
				EventBus.emit_signal("action_pressed", EventBus.ActionEvent.RELOAD, facing)
			return

		if event.is_action("aim"):
			var weapon = get_equipped()

			if weapon == null || !(weapon is Firearm):
				return

			dir = Vector2.ZERO

			if  event.is_action_pressed("aim") && !(Input.is_action_pressed("action")):
				emit_signal("on_aiming_start", self)
				return
			elif event.is_action_released("aim"):
				camera.offset = Vector2.ZERO
				emit_signal("on_aiming_stop", self)
				return

	if Input.is_action_just_pressed("action_alt"):
		emit_signal("on_search_start", self)
		EventBus.emit_signal("action_pressed", EventBus.ActionEvent.USE_KEY, facing)
		return
	elif Input.is_action_just_released("action_alt"):
		emit_signal("on_search_end", self)
		return
	
	if Input.is_action_just_pressed("primary_weapon"):
		equipment.equip_primary()
		emit_signal("on_item_pickedup")
		return
	
	if Input.is_action_just_pressed("secondary_weapon"):
		equipment.equip_secondary()
		emit_signal("on_item_pickedup")
		return

const look_at_dir := Vector2()

func _process_input() -> void:
#	if busy_time == 0.0:
	dir.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	dir.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	var equipped := get_equipped() as BaseItem

	var m_pos : Vector2

	if Global.GameOptions.gameplay.joypad:
		m_pos = get_global_transform_with_canvas().origin.direction_to($Crosshair.position)
	else:
		m_pos = global_position.direction_to(get_global_mouse_position())

	look_at_dir.x = m_pos.x
	look_at_dir.y = m_pos.y
	
	if !PlayerStatus.has_perk(Perk.PERK_TYPE.MOONWALKER):
		if look_at_dir.dot(dir) < 0:
			speed = max_speed * (.18 if aiming else .5)
		else:
			speed = max_speed * (.5 if aiming else 1.0)

#	if busy_time > 0:
#		speed = clamp(speed, 0, 3.7)

	var epsilon := .35

	if look_at_dir.x < -epsilon || look_at_dir.x > epsilon:
		facing.x = look_at_dir.x
		if look_at_dir.y > -epsilon && look_at_dir.y < epsilon:
			facing.y = 0

	if look_at_dir.y < -epsilon || look_at_dir.y > epsilon:
		if look_at_dir.x > -epsilon && look_at_dir.x < epsilon:
			facing.x = 0
		facing.y = look_at_dir.y

	sprite.flip_h = facing.x < 0

func begin_search() -> void:
	if aiming:
		aiming = false

	fsm.travel_to(states.search, null)

func stop_search() -> void:
	fsm.travel_to(states.idle, null)

func kill() -> void:
	if fsm.current_state.get_name().begins_with("die"):
		return

	$Flashlight.enabled = false
	$Vision.enabled = false

	emit_signal("on_death")
	
	if PlayerStatus.death_count >= 1 || !PlayerStatus.has_perk(Perk.PERK_TYPE.ADRENALINE):
		EventBus.emit_signal("on_player_death", self)
	
	fsm.travel_to(states.die, null)
	
func on_hit_by(attacker) -> void:
	.on_hit_by(attacker)
	self.hitpoints -= attacker.damage

	if hitpoints == 0:
#		vel *= vel * attacker.dir
		kill()
	else:
		fsm.travel_to(states.hit, {
			"attacker": attacker
		})

	emit_signal("on_hit")

func get_fuelcan():
	return find_node("*FuelCan*",true, false)

func get_equipment():
	return equipment
	
func get_equipped():
	return equipment.get_child(0)

func equip_item(_item) -> void:
	equipment.equip(_item)
	emit_signal("on_item_pickedup")

func _on_item_pickedup(item) -> void:
	equip_item(item)

func _on_loot_pickedup() -> void:
	PlayerStatus.loot_count += 1
	emit_signal("on_loot_pickedup")

func _on_ProgressWheel_on_progress_complete():
	$ProgressWheel.stop()
	emit_signal("on_search_end")

func _on_Player_on_aiming_start(this):
	aiming = true

func _on_Player_on_aiming_stop(this):
	aiming = false

func set_busy_time(amount) -> void:
	busy_time = max(amount, 0.0)
	emit_signal("on_busy_time_added", busy_time)
