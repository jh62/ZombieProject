class_name PickableWeapon extends Pickable

export var random_drop := false
export(Globals.WeaponNames) var weapon_name := Globals.WeaponNames.PISTOL
export var bullets := 0

var weapons := {
	Globals.WeaponNames.PISTOL:{
		"texture": preload("res://assets/res/weapon/icons/pistol.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn"),
		"bullets": 30
	},
	Globals.WeaponNames.SHOTGUN:{
		"texture": preload("res://assets/res/weapon/icons/shotgun.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Shotgun/Shotgun.tscn"),
		"bullets": 50
	},
	Globals.WeaponNames.SMG:{
		"texture": preload("res://assets/res/weapon/icons/smg.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Smg/Smg.tscn"),
		"bullets": 120
	},
	Globals.WeaponNames.RIFLE:{
		"texture": preload("res://assets/res/weapon/icons/rifle.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/AssaultRifle/AssaultRifle.tscn"),
		"bullets": 120
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

var picked_sound

func _ready():
	if random_drop:
		weapon_name = Globals.WeaponNames.values()[randi()%Globals.WeaponNames.size()]

	if bullets == 0:
		bullets =  weapons.get(weapon_name).bullets

	$Sprite.texture = weapons.get(weapon_name).texture

func get_picked_sound() ->  AudioStream:
	return picked_sound

func _on_Area2D_body_entered(body):
	if !body.is_alive():
		return

	if Global.GameOptions.gameplay.auto_pickup:
		on_picked_up_by(body)
	else:
		label.visible = true
		label.bbcode_text = "[center]Press [color=#fffc00]{0}[/color] to pick up [color=#de2d22]{1}[/color][/center]".format({0:InputMap.get_action_list("action_alt")[0].as_text(),1:Global.WeaponNames.keys()[weapon_name]})

func on_picked_up_by(body) -> void:
	var item = weapons.get(weapon_name).scene.instance()

	if item is Firearm:
		item.bullets = bullets
		picked_sound = item.get_reload_sound().front()

	var current_wep = body.get_equipped()

	if current_wep.get_weapon_type() != Global.WeaponNames.DISARMED:
		if item.get_weapon_type() != current_wep.get_weapon_type():
			_create_drop(body, current_wep)

	EventBus.emit_signal("on_item_pickedup", item)
	.on_picked_up_by(body)

func _create_drop(body, old_weapon) -> void:
	var drop := self.duplicate()
	drop.weapon_name = old_weapon.get_weapon_type()

	if "bullets" in old_weapon:
		drop.bullets = old_weapon.bullets

	EventBus.emit_signal("on_object_spawn", drop, body.global_position)
	print_debug(Globals.WeaponNames.keys()[drop.weapon_name])
