extends Node2D

@onready var cursor: AnimatedSprite2D = $AnimatedSprite2D


func _process(_delta: float) -> void:
	cursor.global_position = get_global_mouse_position()
	if Cursor3d.hook:
		modulate = Color.WHITE
	else:
		modulate = Color.DIM_GRAY
	
