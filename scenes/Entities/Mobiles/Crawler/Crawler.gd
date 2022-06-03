class_name Crawler extends BaseZombie

func _ready():
	add_to_group(Globals.GROUP_SPECIAL)
	
	states = {
		"idle": preload("res://scripts/fsm/states/crawler/CrawlerIdleState.gd").new(self),
		"walk": preload("res://scripts/fsm/states/crawler/CrawlerMoveState.gd").new(self),
		"flee": preload("res://scripts/fsm/states/crawler/CrawlerFleeState.gd").new(self),
		"attack": preload("res://scripts/fsm/states/crawler/CrawlerAttackState.gd").new(self),
		"die": preload("res://scripts/fsm/states/crawler/CrawlerDieState.gd").new(self),
#		"melee": preload("res://scripts/fsm/states/crawler/CrawlerMeleeDeathState.gd").new(self)
#		"hit": preload("res://scripts/fsm/states/crawler/CrawlerHitState.gd"),
	}

	sounds["growl"]  = [
		preload("res://assets/sfx/mobs/crawler/misc/crawler_farcry.wav")
	]
	
func _on_player_death(player : Node2D) -> void:
	if !is_alive():
		return

	target = Global.get_area_point(player.global_position, 20.0)# change to something more meaningful
	fsm.travel_to(states.idle, null)

func on_hit_by(attacker) -> void:
	if Global.GameOptions.graphics.render_blood:
		var angle := PI * rand_range(0.0, 2.0)
		var radius := 10.0	
		var _blood_pos = global_position + Vector2(cos(angle),sin(angle)) * radius
		
		EventBus.emit_signal("spawn_blood", _blood_pos)
	
	fsm.travel_to(states.die, null)
