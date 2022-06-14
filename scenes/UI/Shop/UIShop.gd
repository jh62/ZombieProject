extends Control

enum MENU_ACTIVE {
	NONE = 0,
	WEAPON_DROP_DOWN,
	CONFIRM_DIALOG
}

onready var n_ItemList := $PanelRight/WeaponsContainer/MarginContainer/ItemList
onready var n_PanelMargin := $PanelRight/PanelMargin
onready var n_PerksContainer := $PanelRight/PerksContainer
onready var n_Tween := $TweenItemListTransition
onready var n_Dialog := $CenterContainer/ConfirmationDialog
onready var n_Scroll : VScrollBar

var menu_active = MENU_ACTIVE.NONE
var item_expand_delay := 0.25
var color_traslucid := Color(1.0,1.0,1.0,0.15)

func _ready():
	for n in Global.WeaponNames:
		n_ItemList.add_item(n)
	
	for n in $PanelRight/PerksContainer/GridContainer.get_children():
		n.connect("on_pressed", self, "_on_Perk_pressed")
	
	n_ItemList.rect_size.y = 12
	n_PanelMargin.rect_size.y = n_ItemList.rect_size.y
		
	n_Scroll = n_ItemList.get_child(0)
	n_Scroll.connect("value_changed", self, "_on_ItemList_scroll")
	
	n_Dialog.get_cancel().connect("button_up", self, "_on_ConfirmationDialog_canceled")
	
func _on_ItemList_scroll(value) -> void:
	if n_Tween.is_active():
		return
		
	if menu_active != MENU_ACTIVE.WEAPON_DROP_DOWN:
		n_Scroll.value = 0	

func _on_ItemList_item_selected(index):
	if menu_active != MENU_ACTIVE.NONE && menu_active != MENU_ACTIVE.WEAPON_DROP_DOWN:
		return
		
	if n_Tween.is_active():
		return
		
	n_ItemList.set_item_tooltip_enabled(index, false)
	
	match menu_active:
		MENU_ACTIVE.WEAPON_DROP_DOWN:
			menu_active = MENU_ACTIVE.NONE
			
			n_ItemList.move_item(index, 0)
			n_Tween.interpolate_property(n_ItemList,"rect_min_size", Vector2(96.0, 96.0), Vector2(96.0, 12.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.interpolate_property(n_PanelMargin,"rect_min_size", Vector2(96.0, 96.0), Vector2(96.0, 12.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.interpolate_property(n_PerksContainer,"modulate", color_traslucid, Color.white, item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.start()
		_:
			menu_active = MENU_ACTIVE.WEAPON_DROP_DOWN
			
			n_Tween.interpolate_property(n_ItemList,"rect_min_size", Vector2(96.0, 12.0), Vector2(96.0, 96.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.interpolate_property(n_PanelMargin,"rect_min_size", Vector2(96.0, 12.0), Vector2(96.0, 96.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.interpolate_property(n_PerksContainer,"modulate", Color.white, color_traslucid, item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			n_Tween.start()
	
#	if n_ItemList.rect_min_size.y == 96:
#		menu_active = MENU_ACTIVE.WEAPON_DROP_DOWN
#
#		n_ItemList.move_item(index, 0)
#		n_Tween.interpolate_property(n_ItemList,"rect_min_size", Vector2(96.0, 96.0), Vector2(96.0, 12.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		n_Tween.interpolate_property(n_PanelMargin,"rect_min_size", Vector2(96.0, 96.0), Vector2(96.0, 12.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		n_Tween.interpolate_property(n_PerksContainer,"modulate", color_traslucid, Color.white, item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		n_Tween.start()
#		return	
#
#	n_Tween.interpolate_property(n_ItemList,"rect_min_size", Vector2(96.0, 12.0), Vector2(96.0, 96.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	n_Tween.interpolate_property(n_PanelMargin,"rect_min_size", Vector2(96.0, 12.0), Vector2(96.0, 96.0), item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	n_Tween.interpolate_property(n_PerksContainer,"modulate", Color.white, color_traslucid, item_expand_delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	n_Tween.start()


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
	menu_active = MENU_ACTIVE.CONFIRM_DIALOG
	
	var perk_name = _perk_buton.perk_name
	var perk_price = _perk_buton.perk_price
	n_Dialog.dialog_text = "You wish to purchase {0} for {1}?".format({0:perk_name,1:perk_price})
	n_Dialog.show()

func _on_ConfirmationDialog_confirmed():
	if menu_active != MENU_ACTIVE.CONFIRM_DIALOG:
		return
		
	if active_perk == null:
		return
	
	active_perk.set_purchased(true)
	menu_active = MENU_ACTIVE.NONE

func _on_ConfirmationDialog_canceled():
	menu_active = MENU_ACTIVE.NONE

func _on_ConfirmationDialog_item_rect_changed():
	n_Dialog.rect_position = (get_viewport_rect().size - n_Dialog.rect_size) / 2
