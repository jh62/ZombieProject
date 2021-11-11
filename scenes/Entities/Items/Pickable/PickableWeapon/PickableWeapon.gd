class_name PickableWeapon extends Pickable

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
	WeaponName.MACHETE:{
		"icon": preload("res://assets/res/weapon/icons/machete.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Machete/Machete.tscn")
	}
}

enum WeaponName {
	PISTOL = 0,
	SHOTGUN,
	SMG,
#	RIFLE,
	LEADPIPE,
	MACHETE
}

export var random_drop := false
export(WeaponName) var weapon_name := WeaponName.PISTOL

func _ready():
	if random_drop:
		weapon_name = WeaponName.values()[randi()%WeaponName.size()]
	$Sprite.texture = weapons.get(weapon_name).icon

func on_picked_up_by(body) -> void:
	var item = weapons.get(weapon_name).scene
	EventBus.emit_signal("on_item_pickedup", item.instance())
	queue_free()
