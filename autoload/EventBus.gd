extends Node

# Player signals
signal action_pressed(facing)
signal action_released(facing)

# Pickable signals
signal on_item_pickedup(item)

signal on_bullet_spawn(position, direction)
