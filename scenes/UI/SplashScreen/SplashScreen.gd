extends Control

onready var logo := $TextureRect_Logo
onready var label := $CenterContainer/Label
onready var tween := $CenterContainer/Tween
onready var label_tip := $LabelTips

const TIPS := [
	"Melee weapons are powerfull and [color=red]silent[/color]. Remember that.",
	"Crawlers hate [color=red]light[/color].",
	"Crawlers prey on the [color=red]unaware[/color].",
	"Zombies [color=red]can hear[color=red] from great distances.",
	"Use your perception map wisely.",
	"Avoid making too much noise.",
	"Real magazines [color=red]discard the bullets[/color] left on the clip.",
	"If you go guns crazy, [color=red]stay away[/color] from vehicles.",
	"Don't get overcrowded.",
	"Swords are [color=red]fast[/color].",
	"Crowbars have a wider swing.",
	"Look for the magnifying glass icon for searchable places and objects."
]

func _ready():
	logo.modulate.a = 0.0
	label.modulate.a = 0.0
	label.visible = false

	TIPS.shuffle()
	label_tip.bbcode_text = "[center]Tip: {0}[/center]".format({0:TIPS.front()})

func _process(delta):
	if logo.modulate.a < 1.0:
		return

func set_logo_visibility(amount) -> void:
	logo.modulate.a = clamp(amount, 0.0, 1.0)

func on_finished_loading() -> void:
	label.visible = true
	tween.interpolate_property(label,"modulate",Color(1.0,1.0,1.0,0.0), Color(1.0,1.0,1.0,1.0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_Tween_tween_completed(object, key):
	if label.modulate.a >= 1.0:
		tween.interpolate_property(label,"modulate",Color(1.0,1.0,1.0,1.0), Color(1.0,1.0,1.0,0.0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	else:
		tween.interpolate_property(label,"modulate",Color(1.0,1.0,1.0,0.0), Color(1.0,1.0,1.0,1.0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
