@tool

extends Node3D
@onready var sprite: Sprite3D = $Sprite3D
@export var frames:int



@export var texture_set: Texture2D:
	set(value):
		texture_set = value
		_update_texture()


func _update_texture():
	if texture_set:
		sprite.texture = texture_set
		
func _set_frames():
	if frames > 1:
		pass
