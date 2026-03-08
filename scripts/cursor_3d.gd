extends Area3D

var mouse_position_3d:Vector3
var hook = false

func _physics_process(_delta: float) -> void:
	if not get_tree().current_scene is Node3D:
		return
	_set_mouse_pos()
	var d_trans = Transform3D(basis,mouse_position_3d)
	transform = d_trans

func _set_mouse_pos():
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var camera = viewport.get_camera_3d()
	
	var origin = camera.project_ray_origin(mouse_position)
	var direction = camera.project_ray_normal(mouse_position)
	
	var ray_leght = camera.far
	var end = origin + direction * ray_leght
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	var result = space_state.intersect_ray(query)
	
	mouse_position_3d = result.get("position",end)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("objects"):
		hook = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("objects"):
		hook = false
