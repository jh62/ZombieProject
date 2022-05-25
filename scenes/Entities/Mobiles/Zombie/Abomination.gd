class_name Abomination extends Zombie

func _ready():
	
	SOUNDS  = {
		"growl":[
			preload("res://assets/sfx/mobs/abomination/abomination_cry.wav")
		],
		"attack":[
			preload("res://assets/sfx/mobs/abomination/abomination_cry.wav")
		],
		"die":[
			preload("res://assets/sfx/mobs/abomination/abomination_die.wav")
		],
		"hurt":[
			preload("res://assets/sfx/mobs/abomination/abomination_hurt_1.wav"),
			preload("res://assets/sfx/mobs/abomination/abomination_hurt_2.wav"),
			preload("res://assets/sfx/mobs/abomination/abomination_hurt_3.wav"),
		]
	}
