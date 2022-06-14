extends Control

onready var n_ItemList := $PanelRight/VBoxContainer/MarginContainer/ItemList
onready var n_PanelMargin := $PanelRight/PanelMargin
onready var n_Scroll : VScrollBar

func _ready():
	for n in Global.WeaponNames:
		n_ItemList.add_item(n)
	
	n_ItemList.rect_size.y = 12
	n_PanelMargin.rect_size.y = n_ItemList.rect_size.y
		
	n_Scroll = n_ItemList.get_child(0)
	n_Scroll.connect("value_changed", self, "_on_ItemList_scroll")
	
func _on_ItemList_scroll(value) -> void:
	if n_ItemList.rect_min_size.y < 96:
		n_Scroll.value = 0

func _on_ItemList_item_selected(index):
	n_ItemList.set_item_tooltip_enabled(index, false)
	
	if n_ItemList.rect_min_size.y == 96:
		n_ItemList.move_item(index, 0)
		n_ItemList.rect_min_size.y = 12
		n_ItemList.rect_size.y = 12
		n_PanelMargin.rect_size.y = n_ItemList.rect_size.y
		return
		
	n_ItemList.rect_min_size.y = 96
	n_ItemList.rect_size.y = 96
	n_PanelMargin.rect_size.y = n_ItemList.rect_size.y 
