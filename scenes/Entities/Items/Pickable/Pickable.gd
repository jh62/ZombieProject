class_name Pickable extends Area2D

export var texture : Texture

# virtual methods
func _on_Pickable_body_entered(body: Node) -> void:
	pass

# class methods
func _ready():
	if texture != null:
		_set_texture(texture)
	
func _set_texture(_texture) -> void:
	$AnimatedSprite.frames.add_frame("default", _texture)
