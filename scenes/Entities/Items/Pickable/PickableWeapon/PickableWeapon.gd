class_name PickableWeapon extends Pickable

export var random_drop := false
export(Globals.WeaponNames) var weapon_name := Globals.WeaponNames.PISTOL
export var bullets := 0

var weapons := {
	Globals.WeaponNames.PISTOL:{
		"texture": preload("res://assets/res/weapon/icons/pistol.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn")
	},
	Globals.WeaponNames.SHOTGUN:{
		"texture": preload("res://assets/res/weapon/icons/shotgun.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Shotgun/Shotgun.tscn")
	},
	Globals.WeaponNames.SMG:{
		"texture": preload("res://assets/res/weapon/icons/smg.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/Smg/Smg.tscn")
	},
	Globals.WeaponNames.LEADPIPE:{
		"texture": preload("res://assets/res/weapon/icons/leadpipe.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/LeadPipe/LeadPipe.tscn")
	},
	Globals.WeaponNames.RIFLE:{
		"texture": preload("res://assets/res/weapon/icons/rifle.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/AssaultRifle/AssaultRifle.tscn")
	},
#	Globals.WeaponNames.MACHETE:{
#		"texture": preload("res://assets/res/weapon/icons/machete_icon.tres"),
#		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Machete/Machete.tscn")
#	},
	Globals.WeaponNames.SWORD:{
		"texture": preload("res://assets/res/weapon/icons/sword.tres"),
		"scene": preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Sword/Sword.tscn")
	}
}

var picked_sound

func _ready():
	if random_drop:
		weapon_name = Globals.WeaponNames.values()[randi()%Globals.WeaponNames.size()]
	$Sprite.texture = weapons.get(weapon_name).texture

func get_picked_sound() ->  AudioStream:
	return picked_sound

func _on_Area2D_body_entered(body):
	if !body.is_alive():
		return

	if Globals.GameOptions.gameplay.auto_pickup:
		on_picked_up_by(body)
	else:
		label.visible = true
		label.bbcode_text = "[center]Press [color=#fffc00]{0}[/color] to pick up [color=#de2d22]{1}[/color][/center]".format({0:InputMap.get_action_list("action_alt")[0].as_text(),1:Globals.WeaponNames.keys()[weapon_name]})

func on_picked_up_by(body) -> void:
	_create_drop(body)
	var item = weapons.get(weapon_name).scene.instance()

	if item is Firearm:
		item = item as Firearm
		item.bullets = bullets if (bullets > 0) else item.bullets
		picked_sound = item.get_reload_sound().front()


	EventBus.emit_signal("on_item_pickedup", item)
	.on_picked_up_by(body)

func _create_drop(body) -> void:
	var weapon_current = body.get_equipped().get_weapon_type()
	var drop := self.duplicate()
	drop.weapon_name = weapon_current
	EventBus.emit_signal("on_object_spawn", drop, body.global_position)
