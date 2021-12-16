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
		"texture": preload("res://assets/res/weapon/icons/pistol.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn")
	},
	WeaponName.SHOTGUN:{
		"texture": preload("res://assets/res/weapon/icons/shotgun.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Shotgun/Shotgun.tscn")
	},
	WeaponName.SMG:{
		"texture": preload("res://assets/res/weapon/icons/smg.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Smg/Smg.tscn")
	},
	WeaponName.LEADPIPE:{
		"texture": preload("res://assets/res/weapon/icons/leadpipe.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/LeadPipe/LeadPipe.tscn")
	},
	WeaponName.RIFLE:{
		"texture": preload("res://assets/res/weapon/icons/rifle.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/AssaultRifle/AssaultRifle.tscn")
	},
#	WeaponName.MACHETE:{
#		"texture": preload("res://assets/res/weapon/icons/machete_icon.tres"),
#		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Machete/Machete.tscn")
#	},
	WeaponName.SWORD:{
		"texture": preload("res://assets/res/weapon/icons/sword.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Sword/Sword.tscn")
	}
}

var picked_sound

func _ready():
	if random_drop:
		weapon_name = WeaponName.values()[randi()%WeaponName.size()]
	$Sprite.texture = weapons.get(weapon_name).texture

func get_picked_sound() ->  AudioStream:
	return picked_sound

func _on_Area2D_body_entered(body):
	if Globals.GameOptions.gameplay.auto_pickup:
		on_picked_up_by(body)
	else:
		label.visible = true
		label.bbcode_text = "[center]Press [color=#fffc00]{0}[/color] to pick up [color=#de2d22]{1}[/color][/center]".format({0:InputMap.get_action_list("action_alt")[0].as_text(),1:WeaponName.keys()[weapon_name]})

func on_picked_up_by(body) -> void:
	EventBus.emit_signal("on_object_spawn", self.duplicate(), global_position)

	var item = weapons.get(weapon_name).scene.instance()

	if item is Firearm:
		item = item as Firearm
		item.bullets = bullets if (bullets > 0) else item.bullets
		picked_sound = item.get_reload_sound().front()


	EventBus.emit_signal("on_item_pickedup", item)
	.on_picked_up_by(body)
