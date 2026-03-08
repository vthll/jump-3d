extends CharacterBody3D

enum stateM{idle,walk,jump,fall,pulled,attack}
var state = stateM.idle

var animation = ""

var damage = 10

@onready var animator: AnimationPlayer = $animator
@onready var ground_cast: RayCast3D = $RayCast3D
@onready var coiote_timer: Timer = $coioteTimer
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var hook: Node3D = $hook
@onready var hitbox: Area3D = $hitbox
@onready var hit_shape: CollisionShape3D = $hitbox/CollisionShape3D
@onready var texture: Sprite3D = $texture


var tween:Tween
var tween_criado = false

var pulled_position:Vector3
var pulled_speed = 70

var speed = 12
var gravity = 50
var jump_force = 20
var movement:Vector2

var back = false

var is_floor = false
var floor_position = 0

var target_dir
var target_dist
var in_flip = 0
var txt_size_base = 2.0
var flip = false
var flip_speed = 0.15

var create = false

var rope

var attack = false
var attack_type = 0

func _ready() -> void:
	txt_size_base = texture.scale.x
	_flip()

func _input(event: InputEvent) -> void:
	pass
	if event.is_action_pressed("click") and state != stateM.attack and not Cursor3d.hook:
		_enter_state(stateM.attack)
	if event.is_action_pressed("click") and Cursor3d.hook:
		_enter_state(stateM.pulled)

func _physics_process(_delta: float) -> void:
	if position.y < -100:
		position = Vector3(0,50,0)
	_set_flip(flip)
		
		
	if coiote_timer.is_stopped():
		is_floor = is_on_floor()
	if not ground_cast.is_colliding():
		if state != stateM.fall:
			if coiote_timer.is_stopped():
				coiote_timer.start()
		
	match state:
		stateM.idle: _idle()
		stateM.walk: _walk()
		stateM.jump: _jump()
		stateM.fall: _fall()
		stateM.pulled: _pulled()
		stateM.attack: _attack()
	movement = Input.get_vector("left","right","up","down").normalized()
	move_and_slide()
	if Input.is_action_just_pressed("jump") and is_floor:
		$Jump.play()
		velocity.y = jump_force
		_enter_state(stateM.jump)
		
func _idle():
	if back:
		_set_animation("idle_back")
	else:
		_set_animation("idle_front")
	_apply_gravity()
	if movement:
		_enter_state(stateM.walk)
	velocity.x = 0
	velocity.z = 0
	floor_position = global_position.y
	
func _jump():
	if back:
		_set_animation("jump_back")
	else:
		_set_animation("jump_front")
	_enter_state(stateM.fall)
	
func _fall():
	_apply_gravity()
	_movement()
	if is_on_floor():
		if movement:
			_enter_state(stateM.walk)
		else:
			_enter_state(stateM.idle)
	
func _walk():
	if movement.y < 0:
		back = true
		_set_animation("walk_back")
	if movement.y > 0:
		back = false
		_set_animation("walk_front")
	if movement.x and not movement.y:
		_set_animation("walk_front")
	floor_position = global_position.y
	_apply_gravity()
	if not movement:
		_enter_state(stateM.idle)
		
	_movement()
	
func _pulled():
	velocity = Vector3.ZERO
	if pulled_position.z > global_position.z:
		back = false
	else:
		back = true
	if pulled_position.x > global_position.x:
		flip = false
		_flip()
	else:
		flip = true
		_flip()
		
	
	if back:
		_set_animation("hookshot_back")
	else:
		_set_animation("hookshot_front")
		
	if not create:
		hook._create()
		create = true
	collision.disabled = true
	#var direct = position.direction_to(pulled_position) + Vector3(0,0.3,0)
	#velocity = direct * pulled_speed
	_rop_size()
	velocity.y = position.direction_to(Vector3(0,floor_position,0)).y * pulled_speed
	
	velocity.z = position.direction_to(pulled_position).z * pulled_speed
	velocity.x = position.direction_to(pulled_position).x * pulled_speed
	
	pulled_position.y = floor_position
	if global_position.distance_to(pulled_position) < 3:
		if rope:
			rope.queue_free()
		create = false
		_enter_state(stateM.idle)
		collision.disabled = false
	
func _attack():
	_apply_gravity()
	_set_attack_animation()
	hit_shape.disabled = false
	
	if attack_type == 1:
		_movement()
		
	await animator.animation_finished
	attack = false
	hit_shape.disabled = true
	_enter_state(stateM.idle)
	
	
func _set_attack_animation():
	if attack:
		return
		
	if back:
		if movement:
			attack_type = 1
			_set_animation("attack_walk_back")
		else:
			attack_type = 0
			_set_animation("attack_idle_back")
		
	else:
		if movement:
			attack_type = 1
			_set_animation("attack_walk_front")
		else:
			attack_type = 0
			_set_animation("attack_idle_front")
	attack = true
			
func _set_animation(new_animation:String):
	if animation != new_animation:
		animation = new_animation
	animator.play(animation)
	
func _rop_size():
	if not rope:
		return
	var distance = global_position.distance_to(pulled_position)
	rope.scale = Vector3(1,1,distance)
	#rope.global_position.x = global_position.x
	#rope.global_position.z = global_position.z
	
func _movement():
	_flip()
	velocity.x = movement.x * speed
	velocity.z = movement.y * speed
	
func _flip():
	if movement.x > 0:
		flip = false
		hitbox.position.x = 2
	if  movement.x < 0:
		flip = true
		hitbox.position.x = -2

	
func _set_flip(flip_direction):
	if flip_direction:
		_reset_tween()
		tween.tween_property(texture,"scale:x",-txt_size_base,flip_speed)
		
		if texture.scale.x >= -0.5 and  texture.scale.x <= 0.5:
			texture.flip_h = true
		
	if not flip_direction:
		_reset_tween()
		tween.tween_property(texture,"scale:x",txt_size_base,flip_speed)
		
		if texture.scale.x >= -0.5 and  texture.scale.x <= 0.5:
			texture.flip_h = false
	
	
func _enter_state(new_state):
	if state != new_state:
		state = new_state

func _apply_gravity():
	velocity.y -= gravity * 0.016


func _reset_tween():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween_criado = true

func _on_coiote_timer_timeout() -> void:
	is_floor = false


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		body._hit(global_position,damage)
