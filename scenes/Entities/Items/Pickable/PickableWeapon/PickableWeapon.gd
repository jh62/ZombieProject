class_name PickableWeapon extends Pickable

enum WeaponName {
	PISTOL = 0,
	SHOTGUN,
	SMG,
	RIFLE,
	LEADPIPE,
	MACHETE,
	SWORD
}

export var random_drop := false
export(WeaponName) var weapon_name := WeaponName.PISTOL
export var bullets := 0

var weapons := {
	WeaponName.PISTOL:{
		"icon": preload("res://assets/res/weapon/icons/pistol.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn")
	},
	WeaponName.SHOTGUN:{
		"icon": preload("res://assets/res/weapon/icons/shotgun.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Shotgun/Shotgun.tscn")
	},
	WeaponName.SMG:{
		"icon": preload("res://assets/res/weapon/icons/smg.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Smg/Smg.tscn")
	},
	WeaponName.LEADPIPE:{
		"icon": preload("res://assets/res/weapon/icons/leadpipe.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/LeadPipe/LeadPipe.tscn")
	},
	WeaponName.RIFLE:{
		"icon": preload("res://assets/res/weapon/icons/rifle.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/AssaultRifle/AssaultRifle.tscn")
	},
#	WeaponName.MACHETE:{
#		"icon": preload("res://assets/res/weapon/icons/machete_icon.tres"),
#		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Machete/Machete.tscn")
#	},
	WeaponName.SWORD:{
		"icon": preload("res://assets/res/weapon/icons/sword_icon.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Sword/Sword.tscn")
	}
}

var picked_sound

func _ready():
	if random_drop:
		weapon_name = WeaponName.values()[randi()%WeaponName.size()]
	$Sprite.texture = weapons.get(weapon_name).icon

func get_picked_sound() ->  AudioStream:
	return picked_sound

func on_picked_up_by(body) -> void:
	var item = weapons.get(weapon_name).scene.instance()

	if item is Firearm:
		item = item as Firearm
		item.bullets = bullets if (bullets > 0) else item.bullets
		picked_sound = item.get_reload_sound().front()

	EventBus.emit_signal("on_item_pickedup", item)
	.on_picked_up_by(body)
