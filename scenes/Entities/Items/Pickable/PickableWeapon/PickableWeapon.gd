class_name PickableWeapon extends Pickable

export var random_drop := false
export(Globals.WeaponNames) var weapon_name := Globals.WeaponNames.PISTOL
export var bullets := -1

var magazine := -1

var weapons := {
	Globals.WeaponNames.PISTOL:{
		"texture": preload("res://assets/res/weapon/icons/pistol.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn"),
		"bullets": 45,
		"mag_size": 10
	},
	Globals.WeaponNames.SHOTGUN:{
		"texture": preload("res://assets/res/weapon/icons/shotgun.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Shotgun/Shotgun.tscn"),
		"bullets": 20,
		"mag_size": 6
	},
	Globals.WeaponNames.SMG:{
		"texture": preload("res://assets/res/weapon/icons/smg.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Smg/Smg.tscn"),
		"bullets": 90,
		"mag_size": 30
	},
	Globals.WeaponNames.RIFLE:{
		"texture": preload("res://assets/res/weapon/icons/rifle.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/AssaultRifle/AssaultRifle.tscn"),
		"bullets": 60,
		"mag_size": 30
	},
	Globals.WeaponNames.LEADPIPE:{
		"texture": preload("res://assets/res/weapon/icons/leadpipe.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/LeadPipe/LeadPipe.tscn"),
		"bullets": 0
	},
#	Globals.WeaponNames.MACHETE:{
#		"texture": preload("res://assets/res/weapon/icons/machete_icon.tres"),
#		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Machete/Machete.tscn"),
#		"bullets": 0
#	},
	Globals.WeaponNames.SWORD:{
		"texture": preload("res://assets/res/weapon/icons/sword.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Sword/Sword.tscn"),
		"bullets": 0
	}
}

var auto_picked := false
var picked_sound

func _ready():
	$Sprite.material.set("shader_param/hit_color", Color.yellow)

	if random_drop:
		var keys := weapons.keys()
		var random_weapon : int = keys[randi()%keys.size()]
		weapon_name = Globals.WeaponNames.values()[random_weapon]

#	if bullets == -1:
#		bullets = weapons.get(weapon_name).bullets
#		if Global.GameOptions.gameplay.difficulty == Global.Difficulty.HARD:
#			bullets /= 2

	$Sprite.texture = weapons.get(weapon_name).texture

func get_picked_sound() ->  AudioStream:
	return picked_sound

func _on_Area2D_body_entered(body):
	if !body.is_alive():
		return

	if !auto_picked && Global.GameOptions.gameplay.auto_pickup:
		auto_picked = true
		on_picked_up_by(body)
	else:
		var _weapon_name = Global.WeaponNames.keys()[weapon_name]
		var button = InputMap.get_action_list("action_alt")[0].as_text()

		if Global.GameOptions.gameplay.joypad:
			button = "action"

		var _text = "[center]Press [color=#fffc00]{0}[/color] to pick up [color=#de2d22]{1}[/color][/center]".format({0:button,1:_weapon_name})

		EventBus.emit_signal("on_tooltip", _text)

func on_picked_up_by(body) -> void:
	var weapon_info = weapons.get(weapon_name)
	var item = weapon_info.scene.instance()

	if item is Firearm:
		item.bullets = weapon_info.bullets if (bullets == -1) else bullets
		item.mag_size = weapon_info.mag_size

		if magazine == -1:
			item.reload()
		else:
			item.magazine = magazine

	var current_wep = body.get_equipped()

	var is_melee := current_wep is MeleeWeapon
	var is_firearm : bool = current_wep is Firearm && current_wep.bullets > 0
	var not_same_weapon : bool = item.get_weapon_type() != current_wep.get_weapon_type()

#	if (is_melee || is_firearm) && not_same_weapon:
	if not_same_weapon:
		_create_drop(body, current_wep)

	EventBus.emit_signal("on_tooltip", "")

	EventBus.emit_signal("on_item_pickedup", item)
	.on_picked_up_by(body)

func _create_drop(body, old_weapon) -> void:
	var drop := self.duplicate()
	drop.random_drop = false
	drop.weapon_name = old_weapon.get_weapon_type()
	drop.auto_picked = auto_picked

	if "bullets" in old_weapon:
		drop.bullets = old_weapon.bullets
		drop.magazine = old_weapon.magazine

	EventBus.emit_signal("on_object_spawn", drop, body.global_position)
