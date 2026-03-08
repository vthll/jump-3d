extends CharacterBody3D

enum stateM {idle,patrol,walk}

var life = 100

@onready var navigation: NavigationAgent3D = $Navigation

const HIT_LABEL = preload("uid://blryrkysfhytk")



var target = null
var speed = 8

var gravity = 50

func _physics_process(delta: float) -> void:
	if global_position.y < -50:
		queue_free()
	if not is_on_floor():
		velocity.y -= gravity * delta
	if target:
		navigation.target_position = target.global_transform.origin
		
	var next_location = navigation.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	velocity = velocity.move_toward(new_velocity,0.25)
		
	move_and_slide()
	if life <= 0:
		queue_free()


func _hit(hit_dir:Vector3,damage:int):
	var instance = HIT_LABEL.instantiate()
	var instance_position = Transform3D(basis,global_position + Vector3(0,2,0))
	instance.text = str(damage)
	instance.global_transform = instance_position
	get_tree().current_scene.add_child(instance)
	velocity.y = 20
	velocity.x = -position.direction_to(hit_dir).x * 10
	life -= damage

func _on_range_body_entered(body: Node3D) -> void:
	target = body


func _on_range_body_exited(body: Node3D) -> void:
	if body == target:
		target = null
		
