extends Node3D

@export var player:CharacterBody3D

@onready var rope = preload("res://scenes/player/rope.tscn")

var new_hook_position:Vector3
var mouse_position_3d:Vector3


var distance_hook = 0
var limit_hook = 40

var tween:Tween
	

func _process(_delta: float) -> void:
	_set_mouse_pos()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if Cursor3d.hook:
			_set_distance()


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

func _create():
	var trs = Transform3D(basis,mouse_position_3d)
	#var mouse_2d = Vector2(mouse_position_3d.x,mouse_position_3d.z)
	var final = player.global_position.distance_to(mouse_position_3d)
	var instance = rope.instantiate()
	instance.transform = trs
	instance.position.y = player.position.y
	#tween.tween_property(instance,"scale",Vector3(1,1,final),0.2)
	instance.scale = Vector3(1,1,final)
	get_tree().current_scene.add_child(instance)
	instance.look_at(player.position)
	#instance.look_at(Vector3(player.position.x,player.global_position.y,mouse_2d.y))
	player.rope = instance

func _set_distance():
	if not player:
		return
	distance_hook = player.global_position.distance_to(mouse_position_3d)
	if distance_hook <= limit_hook:
		player.pulled_position = mouse_position_3d
		#_create()
		_pulled()
	


func _pulled():
	if not player:
		return
	player.state = player.stateM.pulled

func _reset_tween():
	if tween:
		tween.kill()
	tween = create_tween()
