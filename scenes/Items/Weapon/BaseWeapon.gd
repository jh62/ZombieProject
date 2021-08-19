class_name BaseWeapon extends BaseItem

var texture_shoot : Texture

var damage := 0.0
var fire_rate := 0.0
var bullets := 0
var magazine := 0

func get_texture(current_state) -> Texture:
	var texture := .get_texture(current_state)

	if texture != null:
		return texture

	match current_state:
		"action":
			return texture_shoot

	return null
