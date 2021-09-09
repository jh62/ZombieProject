extends Node

enum ActionEvent{
	USE,
	RELOAD
}

# Player signals
signal action_pressed(action_name, facing)
signal action_released(action_name, facing)

# Pickable signals
signal on_item_pickedup(item)

# Entity signals
signal on_bullet_spawn(position, direction, damage)
signal on_mob_spawn(position)
