tool
extends VBoxContainer

signal on_pressed(perk_button)
signal on_purchased(perk_name, perk_price)

enum PERK_TYPE {
	FAST_RELOAD,
	MOONWALKER,
	FIXXXER,
	FREE_FIRE,
	TOUGH_GUY,
	ADRENALINE,
	HOLLYWOOD_MAG,
	SHADOW_DANCER
}

export(PERK_TYPE) var perk_icon := 0 setget set_perk_icon
export var perk_name := ""
export var perk_price := 0
export var purchased := false

onready var n_Panel := $Panel
onready var n_Label := $Panel/Label
onready var n_Button := $TextureButton
onready var n_Tween := $Tween
onready var PanelStyle := StyleBoxFlat.new()

func _ready():
	n_Panel.set("custom_styles/panel", StyleBoxFlat.new())
	
	if purchased:
		n_Panel.get("custom_styles/panel").bg_color = Color.webgreen
		n_Panel.get("custom_styles/panel").border_color = Color.darkgreen
		n_Label.text = "Purchased"
	else:
		n_Panel.get("custom_styles/panel").bg_color = Color.darkslategray
		n_Panel.get("custom_styles/panel").border_color = Color.gray
		n_Label.text = "${0}".format({0:perk_price})
	
	set_perk_name(perk_name)
	set_perk_price(perk_price)
	set_perk_icon(perk_icon)

func set_perk_name(_name) -> void:
	perk_name = _name.strip_edges()
	
func set_perk_price(_val) -> void:
	perk_price = _val
	n_Label.text = "${0}".format({0:_val})

func set_purchased(_purchased) -> void:
	purchased = _purchased
	
	if purchased:
		$TextureButton.disconnect("button_up", self, "_on_TextureButton_button_up")
		
		n_Panel.get("custom_styles/panel").bg_color = Color8(20, 150, 10,255)
		n_Panel.get("custom_styles/panel").border_color = Color.darkgreen
		n_Label.text = "Purchased"
		
		n_Tween.interpolate_property(n_Label, "percent_visible", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		n_Tween.start()
		
		emit_signal("on_purchased", perk_name, perk_price)		
	else:
		n_Panel.get("custom_styles/panel").bg_color = Color.darkslategray
		n_Panel.get("custom_styles/panel").border_color = Color.gray
		set_perk_price(perk_price)	

func _on_TextureButton_button_up():
	emit_signal("on_pressed", self)

func set_perk_icon(_icon_idx : int) -> void:
	perk_icon = wrapi(_icon_idx, 0, PERK_TYPE.size())
	
	if !is_inside_tree():
		return
	
	var button = $TextureButton/TextureRect
	
	match perk_icon:
		PERK_TYPE.ADRENALINE:
			button.texture = preload("res://assets/ui/perk_adrenaline.tres")		
		PERK_TYPE.FIXXXER:
			button.texture = preload("res://assets/ui/perk_fixxxer.tres")
		PERK_TYPE.HOLLYWOOD_MAG:
			button.texture = preload("res://assets/ui/perk_hollywood_mag.tres")
		PERK_TYPE.FREE_FIRE:
			button.texture = preload("res://assets/ui/perk_free_fire.tres")
		PERK_TYPE.MOONWALKER:
			button.texture = preload("res://assets/ui/perk_moonwalker.tres")
		PERK_TYPE.TOUGH_GUY:
			button.texture = preload("res://assets/ui/perk_tough_guy.tres")	
		PERK_TYPE.SHADOW_DANCER:
			button.texture = preload("res://assets/ui/perk_shadow_dancer.tres")	
		_:
			button.texture = preload("res://assets/ui/perk_fast_reload.tres")
