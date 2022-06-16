extends Control

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
		"Why excatly are you here?",
		"Can I help you, mate?",
		"You got money, right?",
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

const MIN_QUOTE_DELAY := 7.0
const MAX_QUOTE_DELAY = 15.0

enum MENU_ACTIVE {
	NONE = 0,
	WEAPON_DROP_DOWN,
	CONFIRM_DIALOG
}

onready var n_ItemList := $PanelRight/WeaponsContainer/MarginContainer/ItemList
onready var n_PanelAmmo := $PanelRight/AmmoContainer
onready var n_AmmoCountLabel := $PanelRight/AmmoContainer/MarginContainer/VBoxContainer/LabelAmmoCount
onready var n_AmmoPlus := $PanelRight/AmmoContainer/MarginContainer/VBoxContainer/HBoxContainer/ButtonPlus
onready var n_AmmoMinus := $PanelRight/AmmoContainer/MarginContainer/VBoxContainer/HBoxContainer/ButtonMinus
onready var n_PanelMargin := $PanelRight/PanelMargin
onready var n_PerksContainer := $PanelRight/PerksContainer
onready var n_Tween := $TweenItemListTransition
onready var n_Dialog := $CenterContainer/ConfirmationDialog
onready var n_ChatLabel := $ChatBubbleTexture/MarginContainer/ChatLabel
onready var n_LabelPrice := $PanelRight/MarginContainer/LabelPrice
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

func _ready():
	for _weapon_name in Global.WeaponNames:
		var _weapon_idx = Global.WeaponNames.get(_weapon_name)
		
		if _weapon_idx == Global.WeaponNames.DISARMED:
			continue
		
		var _price = PRICES.get(_weapon_idx)
		n_ItemList.add_item("{0} ${1}".format({0:_weapon_name, 1:_price}))
	
	for n in $PanelRight/PerksContainer/GridContainer.get_children():
		n.connect("on_pressed", self, "_on_Perk_pressed")
		n.connect("on_purchased", self, "_on_Perk_purchased")
	
	n_ItemList.rect_size.y = 12
	n_PanelMargin.rect_size.y = n_ItemList.rect_size.y
		
	n_Scroll = n_ItemList.get_child(0)
	n_Scroll.connect("value_changed", self, "_on_ItemList_scroll")
	
	n_Dialog.get_cancel().connect("button_up", self, "_on_ConfirmationDialog_canceled")
	
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
	
func _get_random_quote(_key) -> String:
	var quotes = QUOTES.get(_key, "default")
	quotes.shuffle()
	return quotes.front() as String
	
func _on_ItemList_scroll(value) -> void:
	if n_Tween.is_active():
		return
		
	if menu_active != MENU_ACTIVE.WEAPON_DROP_DOWN:
		n_Scroll.value = 0
	
	_play("scroll")

func _on_ItemList_item_selected(index):
#	if menu_active != MENU_ACTIVE.NONE && menu_active != MENU_ACTIVE.WEAPON_DROP_DOWN:
#		return

	var _wep = PlayerStatus.get_weapon(1)
	
	if _wep != null:
		n_ChatLabel.text = "Your weapon has {0} bullets left!".format({0:_wep.bullets})
		n_AnimationPlayerMouth.play("talk")
		return
		
	if n_Tween.is_active():
		return
		
	n_ItemList.set_item_tooltip_enabled(index, false)
	
	if menu_active == MENU_ACTIVE.WEAPON_DROP_DOWN:
		if last_selection_update / last_random_chat_delay >= .25:
			n_ChatLabel.text = _get_random_quote("annoyed")
			n_AnimationPlayerMouth.play("talk")
	
	match menu_active:
		MENU_ACTIVE.WEAPON_DROP_DOWN:
			set_menu_active(MENU_ACTIVE.NONE)
			
			n_ItemList.move_item(index, 0)
		
			var _item_name : String = n_ItemList.get_item_text(0)
			var _item_price = _item_name.rsplit("$")[1]
			$PanelRight/MarginContainer/LabelPrice.text = "TOTAL PRICE: ${0}".format({0:_item_price})
	
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

func _on_Perk_pressed(_perk_buton):
	if menu_active != MENU_ACTIVE.NONE:
		return
		
	active_perk = _perk_buton
	set_menu_active(MENU_ACTIVE.CONFIRM_DIALOG)
	
	var perk_name = _perk_buton.perk_name
	var perk_price = _perk_buton.perk_price
	n_Dialog.dialog_text = "You wish to purchase {0} for {1}?".format({0:perk_name,1:perk_price})
	n_Dialog.show()
	_play("dropdown")

func _on_Perk_purchased(_name, _price) -> void:
	n_ChatLabel.text = "{0} is a nice purchase, mate!".format({0:_name})
	$AnimationPlayerMouth.play("talk")
	_play("buy")

func _on_ConfirmationDialog_confirmed():
	if menu_active != MENU_ACTIVE.CONFIRM_DIALOG:
		return
		
	if active_perk == null:
		return
	
	active_perk.set_purchased(true)
	set_menu_active(MENU_ACTIVE.NONE)
	_play("buy")

func _on_ConfirmationDialog_canceled():
	set_menu_active(MENU_ACTIVE.NONE)
	_play("cancel")

func _on_ConfirmationDialog_item_rect_changed():
	n_Dialog.rect_position = (get_viewport_rect().size - n_Dialog.rect_size) / 2

func set_menu_active(_active_menu) -> void:
	if _active_menu == menu_active:
		return
		
	menu_active = _active_menu
	
	match menu_active:
		MENU_ACTIVE.WEAPON_DROP_DOWN:
			n_PanelAmmo.modulate.a = 0.15
			n_AmmoPlus.disabled = true
			n_AmmoMinus.disabled = true
			continue
		MENU_ACTIVE.NONE:
			n_PanelAmmo.modulate.a = 1.0
			n_AmmoPlus.disabled = false
			n_AmmoMinus.disabled = false
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
