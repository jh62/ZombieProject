class_name LootItem extends Pickable

const TEXTURES := ["res://assets/res/items/beer_can.tres","res://assets/res/items/bullets.tres","res://assets/res/items/cd_rom.tres","res://assets/res/items/cigpack.tres","res://assets/res/items/razblade.tres","res://assets/res/items/water_bottle.tres"]

func _ready():
	var tex : Texture = load(TEXTURES[randi() % TEXTURES.size()])
	_set_texture(tex)

func _on_Pickable_body_entered(body: Node) -> void:
	EventBus.emit_signal("on_loot_pickedup", -1)
	queue_free()
