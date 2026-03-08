extends Label3D


func _ready() -> void:
	var damage_tween = get_tree().create_tween()
	damage_tween.set_parallel(true)
	damage_tween.tween_property(self,"scale",Vector3(0.7,0.7,0.7),0.2)
	damage_tween.tween_property(self,"scale",Vector3(0.5,0.5,0.5),0.2).set_delay(0.4)
	damage_tween.tween_property(self,"position:y",global_position.y + 8 ,0.5).set_delay(0.4)
	await damage_tween.finished
	queue_free()
	
