extends VBoxContainer

signal on_pressed(perk_button)
signal on_purchased(perk_name, perk_price)

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

func set_perk_name(_name) -> void:
	perk_name = _name.strip_edges()
	n_Button.hint_tooltip = perk_name
	
func set_perk_price(_val) -> void:
	perk_price = _val
	n_Label.text = "${0}".format({0:_val})

func set_purchased(_purchased) -> void:
	purchased = _purchased
	
	if purchased:
		$TextureButton.disconnect("button_up", self, "_on_TextureButton_button_up")
		
		n_Panel.get("custom_styles/panel").bg_color = Color.green
		n_Panel.get("custom_styles/panel").border_color = Color.darkgreen
		n_Label.text = "Purchased"
		
		n_Tween.interpolate_property(n_Label, "percent_visible", 0.0, 1.0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		n_Tween.start()
		
		emit_signal("on_purchased", perk_name, perk_price)		
	else:
		n_Panel.get("custom_styles/panel").bg_color = Color.darkslategray
		n_Panel.get("custom_styles/panel").border_color = Color.gray
		set_perk_price(perk_price)	

func _on_TextureButton_button_up():
	emit_signal("on_pressed", self)
