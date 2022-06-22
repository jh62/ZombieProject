extends Control

const MainScene := preload("res://scenes/Main.tscn")

const SOUNDS := {
	"click": preload("res://assets/sfx/ui/merchant/merchant_click.wav"),
	"cancel": preload("res://assets/sfx/ui/ui_cancel.wav"),
	"buy": preload("res://assets/sfx/ui/merchant/merchant_buy_item.wav"),
	"open": preload("res://assets/sfx/ui/merchant/merchant_item_window.wav"),
	"scroll": preload("res://assets/sfx/ui/merchant/merchant_scroll.wav"),
	"switch": preload("res://assets/sfx/ui/merchant/merchant_switch.wav"),
	"dropdown": preload("res://assets/sfx/ui/merchant/merchant_dropdown.wav")
}

const QUOTES := {
	"default": [
		"I don't know about that"
	],
	"bored": [
		"Why exactly are you here?",
		"Can I help you, friend?",
		"You got cash, right?",
		"I'll just look at you 'till you buy somethin'"
	],
	"undecided": [
		"Pick one!",
		"Buyers remorse, huh?",
		"Yes, that one!",
		"You're lucky it's the apocalypse and I got notin' to do."
	],
	"annoyed": [
		"Finally!",
		"That was quick... just so you know, i was beign sarcastic."
	],
	"broke":[
		"You ain't got the cash for that!",
		"I ain't runnin' a charity!",
		"I wasn't born yesterday, mate!",
		"You're broke, mate!",
		"I ain't giving that for free!",
		"How about gettin' some cash before comin' in here?",
		"There's a price tag in there! I suggest you read it.",
		"You cheap bastard."
	]
}

const PRICES := {
	Globals.WeaponNames.LEADPIPE: 50,
	Globals.WeaponNames.SWORD: 80,
	Globals.WeaponNames.PISTOL: 120,
	Globals.WeaponNames.SHOTGUN: 220,
	Globals.WeaponNames.SMG: 280,
	Globals.WeaponNames.RIFLE: 320,
}

const PRIMARY_WEAPONS_LIST := [
	Globals.WeaponNames.PISTOL,
	Globals.WeaponNames.SHOTGUN,
	Globals.WeaponNames.SMG,
	Globals.WeaponNames.RIFLE
]

const SECONDARY_WEAPONS_LIST := [
	Globals.WeaponNames.LEADPIPE,
	Globals.WeaponNames.SWORD,
]

const WEAPONS_SCENES := {
	Globals.WeaponNames.PISTOL: preload("res://scenes/Entities/Items/Weapon/Pistol/Pistol.tscn"),
	Globals.WeaponNames.SHOTGUN: preload("res://scenes/Entities/Items/Weapon/Shotgun/Shotgun.tscn"),
	Globals.WeaponNames.SMG: preload("res://scenes/Entities/Items/Weapon/Smg/Smg.tscn"),
	Globals.WeaponNames.RIFLE: preload("res://scenes/Entities/Items/Weapon/AssaultRifle/AssaultRifle.tscn"),
	Globals.WeaponNames.LEADPIPE: preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/LeadPipe/LeadPipe.tscn"),
	Globals.WeaponNames.SWORD: preload("res://scenes/Entities/Items/Weapon/MeleeWeapon/Sword/Sword.tscn"),
}

const MIN_QUOTE_DELAY := 15.0
const MAX_QUOTE_DELAY = 45.0

enum MENU_ACTIVE {
	NONE = 0,
	WARNING,
	WEAPON_DROP_DOWN,
	CONFIRM_DIALOG_PERK,
	CONFIRM_DIALOG_WEAPON,
	QUIT_CONFIRM,
}

onready var n_ItemList := $PanelRight/WeaponsContainer/MarginContainer/ItemList
onready var n_PanelAmmo := $PanelRight/AmmoContainer
onready var n_AmmoCountLabel := $PanelRight/AmmoContainer/MarginContainer/VBoxContainer/LabelAmmoCount
onready var n_ButtonPrimary := $PanelRight/WeaponType/ButtonPrimary
onready var n_ButtonSecondary := $PanelRight/WeaponType/ButtonSecondary
onready var n_PanelMargin := $PanelRight/PanelMargin
onready var n_PerksContainer := $PanelRight/PerksContainer
onready var n_AmmoPanel := $PanelRight/AmmoContainer
onready var n_Tween := $TweenItemListTransition
onready var n_Dialog := $ConfirmationDialogContainer/ConfirmationDialog
onready var n_DialogWarning := $WarningDialogContainer/WarningDialog
onready var n_ChatLabel := $ChatBubbleTexture/MarginContainer/ChatLabel
onready var n_LabelCash := $Cash/CenterContainer/PanelCash/CenterContainer/LabelCash
onready var n_ButtonAmmo := $PanelRight/AmmoContainer/CenterContainer/ButtonAmmo
onready var n_AnimationPlayerMouth := $AnimationPlayerMouth
onready var n_AnimationPlayerEyes := $AnimationPlayerEyes
onready var n_Sounds := $Sounds
onready var n_Music := $Music
onready var n_Scroll : VScrollBar

var menu_active = MENU_ACTIVE.NONE
var item_expand_delay := 0.25
var color_traslucid := Color(1.0,1.0,1.0,0.15)
var last_selection_update := 0.0
var last_random_chat_delay := MAX_QUOTE_DELAY

var selected_weapon_idx := 0
var selected_weapon_name := ""
var selected_weapon_price := 0
var ammo_count := 0
var ammo_price := 0
var current_cash := 0 setget set_cash

func _ready():
	for n in $PanelRight/PerksContainer/GridContainer.get_children():
		n.connect("on_pressed", self, "_on_Perk_pressed")
		n.connect("on_purchased", self, "_on_Perk_purchased")
		
	set_cash(PlayerStatus.get_cash())
	
	n_ItemList.rect_size.y = 12
	n_PanelMargin.rect_size.y = n_ItemList.rect_size.y
		
	n_Scroll = n_ItemList.get_child(0)
	n_Scroll.connect("value_changed", self, "_on_ItemList_scroll")
	
	n_Dialog.get_cancel().connect("button_up", self, "_on_ConfirmationDialog_canceled")
	n_Dialog.connect("visibility_changed", self, "_on_Dialog_visibility_changed")
	n_DialogWarning.connect("visibility_changed", self, "_on_WarningDialog_visibility_changed")
	n_Dialog.window_title
	
	_populate_weapon_list()	
	yield(get_tree().create_timer(0.05), "timeout")
	
func _get_player_weapon() -> Firearm:
	var _idx = 0 if n_ButtonPrimary.pressed else 1
	var _current_weapon = PlayerStatus.get_weapon(_idx)
	return _current_weapon
		
func _process(delta):
	last_selection_update += delta
	
#	print_debug(last_selection_update / last_random_chat_delay)
	
	if last_selection_update < last_random_chat_delay:
		return
	
	last_selection_update = 0.0
	last_random_chat_delay = rand_range(MIN_QUOTE_DELAY, MAX_QUOTE_DELAY)
	
	match menu_active:
		MENU_ACTIVE.NONE:
			n_ChatLabel.text = _get_random_quote("bored")
			n_AnimationPlayerMouth.play("talk")
		MENU_ACTIVE.WEAPON_DROP_DOWN:
			n_ChatLabel.text = _get_random_quote("undecided")
			n_AnimationPlayerMouth.play("talk")
		_:
			return
			
func is_primary_weapon() -> bool:
	return n_ButtonPrimary.pressed && !n_ButtonSecondary.pressed
	
func _populate_weapon_list() -> void:
	n_ItemList.clear()
	
	var _weapon_list := PRIMARY_WEAPONS_LIST if is_primary_weapon() else SECONDARY_WEAPONS_LIST
	var _weapon_slot := 0 if is_primary_weapon() else 1
	var _p_weapon = PlayerStatus.get_weapon(_weapon_slot)
	
	var _item_idx := 0
	
	for _w in _weapon_list:
		var _weapon_name = Global.WeaponNames.keys()[_w]
		var _weapon_idx = Global.WeaponNames.get(_weapon_name)
		
		var owned = _p_weapon != null && _weapon_idx == _p_weapon.get_weapon_type()
		var _price = PRICES.get(_weapon_idx)
		
		if owned:
			n_ItemList.add_item("{0} (owned)".format({0:_weapon_name}), null, false)
			n_ItemList.move_item(_item_idx, 0)
			n_ItemList.set_item_metadata(0, _weapon_idx)
			update_ammo_price(_price)
		else:
			n_ItemList.add_item("{0} ${1}".format({0:_weapon_name, 1:_price}))
			n_ItemList.set_item_metadata(_item_idx, _weapon_idx)
			
		_item_idx += 1
	
func _get_random_quote(_key) -> String:
	var quotes = QUOTES.get(_key, "default")
	quotes.shuffle()
	return quotes.front() as String

#func update_price(_idx := 0) -> void:
#	var _item_name = n_ItemList.get_item_text(_idx)
#	var _item_price = _item_name.rsplit("$")[1]
#	n_LabelPrice.text = "TOTAL PRICE: ${0}".format({0:_item_price})
	
func _on_ItemList_scroll(value) -> void:
	if n_Tween.is_active():
		return
		
#	if menu_active != MENU_ACTIVE.WEAPON_DROP_DOWN:
#		n_Scroll.value = 0
	
	_play("scroll")

func _on_ItemList_item_selected(index):
#	if menu_active != MENU_ACTIVE.NONE && menu_active != MENU_ACTIVE.WEAPON_DROP_DOWN:
#		return
		
	if n_Tween.is_active():
		return
		
	n_ItemList.set_item_tooltip_enabled(index, false)
	
	if menu_active == MENU_ACTIVE.WEAPON_DROP_DOWN:
		if last_selection_update / last_random_chat_delay >= .25:
			n_ChatLabel.text = _get_random_quote("annoyed")
			n_AnimationPlayerMouth.play("talk")
	
	match menu_active:
		MENU_ACTIVE.WEAPON_DROP_DOWN:
			set_menu_active(MENU_ACTIVE.CONFIRM_DIALOG_WEAPON)
			_on_weapon_selected(index)
	
			n_Tween.interpolate_property(n_ItemList,"rect_min_size", Vector2(96.0, 96.0), Vector2(96.0, 12.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.interpolate_property(n_PanelMargin,"rect_min_size", Vector2(96.0, 96.0), Vector2(96.0, 12.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.interpolate_property(n_PerksContainer,"modulate", color_traslucid, Color.white, item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.start()
			
			_play("click")
		_:
			set_menu_active(MENU_ACTIVE.WEAPON_DROP_DOWN)
			
			n_Tween.interpolate_property(n_ItemList,"rect_min_size", Vector2(96.0, 12.0), Vector2(96.0, 96.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.interpolate_property(n_PanelMargin,"rect_min_size", Vector2(96.0, 12.0), Vector2(96.0, 96.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.interpolate_property(n_PerksContainer,"modulate", Color.white, color_traslucid, item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.start()
			
			_play("dropdown")

func _on_ItemList_gui_input(event : InputEvent):
	if !event is InputEventMouseMotion:
		return
	
	if menu_active != MENU_ACTIVE.WEAPON_DROP_DOWN:
		return
	
	if n_Tween.is_active():
		return
		
	var item = n_ItemList.get_item_at_position(event.position, false)
	n_ItemList.select(item)

var active_perk

func _on_weapon_selected(_weapon_idx):
	var _weapon_data = n_ItemList.get_item_text(_weapon_idx)
	
	if _weapon_data.ends_with("(owned)"):
		return
	
	_weapon_data = _weapon_data.split("$")
	
	var _name = _weapon_data[0]
	var _price = _weapon_data[1]
	
	var _player_weapon = _get_player_weapon()
	
	if _player_weapon != null && Global.WeaponNames.keys()[_player_weapon.get_weapon_type()] == _name:
		set_menu_active(MENU_ACTIVE.NONE)
		return
	
	set_menu_active(MENU_ACTIVE.CONFIRM_DIALOG_WEAPON)
	
	selected_weapon_idx = n_ItemList.get_item_metadata(_weapon_idx)
	selected_weapon_name = _name
	selected_weapon_price = int(_price)
	
	n_Dialog.dialog_text = "Do you wish to purchase {0} for ${1}?".format({0:_name,1:_price})
	n_Dialog.show()
	_play("dropdown")

func _on_Perk_pressed(_perk_buton):
	if menu_active != MENU_ACTIVE.NONE:
		return
		
	active_perk = _perk_buton
	set_menu_active(MENU_ACTIVE.CONFIRM_DIALOG_PERK)
	
	var perk_name = _perk_buton.perk_name
	var perk_price = _perk_buton.perk_price
	
	n_Dialog.dialog_text = "Do you wish to purchase the {0} perk for {1}?".format({0:perk_name,1:perk_price})
	n_Dialog.show()
	_play("dropdown")

func _on_Perk_purchased(_name, _price) -> void:
	self.current_cash -= _price
	active_perk.set_purchased(true)
		
	n_ChatLabel.text = "{0} is a nice purchase, mate!".format({0:_name})
	$AnimationPlayerMouth.play("talk")
	_play("buy")

func _on_ConfirmationDialog_confirmed():
	var _menu_active = menu_active
	set_menu_active(MENU_ACTIVE.NONE)
	
	match _menu_active:
		MENU_ACTIVE.CONFIRM_DIALOG_PERK:
			if active_perk.perk_price > current_cash:
				n_ChatLabel.text = _get_random_quote("broke")
				n_AnimationPlayerMouth.play("talk")
				return
				
			_play("buy")
		MENU_ACTIVE.CONFIRM_DIALOG_WEAPON:
			if selected_weapon_price > current_cash:
				n_ChatLabel.text = _get_random_quote("broke")
				n_AnimationPlayerMouth.play("talk")
				return
				
			self.current_cash -= selected_weapon_price
			
			var is_primary = n_ButtonPrimary.pressed && !n_ButtonSecondary.pressed
			
			if is_primary:
				PlayerStatus.set_weapon(WEAPONS_SCENES.get(selected_weapon_idx), 0, 100)
				update_ammo_price(selected_weapon_price)
			else:
				PlayerStatus.set_weapon(WEAPONS_SCENES.get(selected_weapon_idx))
			
			_populate_weapon_list()
			_play("buy")
		MENU_ACTIVE.QUIT_CONFIRM:
			get_tree().change_scene_to(MainScene)
			call_deferred("queue_free")	
		_:
			return

func _on_ConfirmationDialog_canceled():
	set_menu_active(MENU_ACTIVE.NONE)
	_play("cancel")

func update_ammo_price(_weapon_price) -> void:
	ammo_price = ceil(_weapon_price * 0.02)
	n_ButtonAmmo.hint_tooltip = "${0} each magazine".format({0:ammo_price})
	
func set_cash(_value) -> void:
	current_cash = max(0, _value)
	n_LabelCash.text = "${0}".format({0:current_cash})
	
func set_menu_active(_active_menu) -> void:
	if _active_menu == menu_active:
		return
		
	menu_active = _active_menu
	
	match menu_active:
		MENU_ACTIVE.WEAPON_DROP_DOWN:
			n_PanelAmmo.modulate.a = 0.15
			continue
		MENU_ACTIVE.NONE:
			n_PanelAmmo.modulate.a = 1.0
			continue
		_:
			last_selection_update = 0.0
	
func _play(_sound_name) -> void:
	var _sound = SOUNDS.get(_sound_name, "click")
	n_Sounds.stream = _sound
	n_Sounds.play()

func _on_ButtonPlus_button_up():
	n_AmmoCountLabel.text = "1"
	_play("click")

func _on_ButtonMinus_button_up():
	_play("click")

func _on_ButtonPrimary_button_up():
	_populate_weapon_list()
	n_AmmoPanel.visible = true

func _on_ButtonSecondary_button_up():
	_populate_weapon_list()
	n_AmmoPanel.visible = false

func _on_AnimationPlayerMouth_animation_changed(old_name, new_name):
	n_AnimationPlayerMouth.stop()
	n_AnimationPlayerMouth.play(new_name)

func _on_ButtonExit_button_up():
	set_menu_active(MENU_ACTIVE.QUIT_CONFIRM)
	n_Dialog.dialog_text = "Are you sure you want to exit the shop and continue your journey?"
	n_Dialog.show()

func _on_ButtonAmmo_button_up():
	if current_cash < ammo_price:
		n_ChatLabel.text = _get_random_quote("broke")
		n_AnimationPlayerMouth.play("talk")
		return
		
	var p_weapon = PlayerStatus.get_weapon(0)
	
	if p_weapon.bullets >= p_weapon.mag_size * 12:
		set_menu_active(MENU_ACTIVE.WARNING)		
		n_DialogWarning.dialog_text = "You can't carry anymore of that!"
		n_DialogWarning.show()
		return
		
	p_weapon.bullets += p_weapon.mag_size
	
	self.current_cash -= ammo_price
	_play("buy")

func _on_Dialog_visibility_changed():
	if n_Dialog.visible:
		$ConfirmationDialogContainer.mouse_filter = MOUSE_FILTER_STOP
	else:
		$ConfirmationDialogContainer.mouse_filter = MOUSE_FILTER_IGNORE
		
func _on_WarningDialog_visibility_changed():
	if n_DialogWarning.visible:
		$WarningDialogContainer.mouse_filter = MOUSE_FILTER_STOP
	else:
		$WarningDialogContainer.mouse_filter = MOUSE_FILTER_IGNORE

func _on_ConfirmationDialog_item_rect_changed():
	n_Dialog.popup_centered()

func _on_WarningDialog_item_rect_changed():
	n_DialogWarning.popup_centered()
