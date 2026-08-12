extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var wm : WorldManager

@export var base_speed : int = 5
@export var mouse_sensitivity : float = 0.002
@export var jump_velocity: float = 5.0
@export var run_multiplier : float = 2.0

var speed : float

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#if get_node("../WorldManager") != null:
	#	wm = get_node("../WorldManager")
	#	print("WM is %s" % [wm])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		get_tree().quit()
	if event.is_action_pressed("alt"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func interact_with_voxel(is_placing: bool, new_block_id: int = 1) -> void:
	if not raycast.is_colliding():
		return
	var collider = raycast.get_collider()
	if not collider is Sector:
		return
	var sector: Sector = collider
	var hit_point: Vector3 = raycast.get_collision_point()
	var hit_normal: Vector3 = raycast.get_collision_normal()
	var local_point: Vector3 = sector.to_local(hit_point)
	var local_normal: Vector3 = sector.global_transform.basis.inverse() * hit_normal
	local_normal = local_normal.normalized()
	
	const EPSILON: float = 0.001
	var target_voxel_pos: Vector3
	
	if is_placing:
		# Установка: сдвигаемся НАРУЖУ по нормали
		target_voxel_pos = local_point + (local_normal * EPSILON)
	else:
		# Разрушение: сдвигаемся ВНУТРЬ против нормали
		target_voxel_pos = local_point - (local_normal * EPSILON)
		
	# 4. Округляем вниз для получения целых координат сетки
	var voxel_coords: Vector3i = Vector3i(target_voxel_pos.floor())
	
	# 5. Передаем координаты в API сектора
	if is_placing:
		sector.set_block(voxel_coords.x, voxel_coords.y, voxel_coords.z, new_block_id)
	else:
		sector.set_block(voxel_coords.x, voxel_coords.y, voxel_coords.z, 0) # 0 - Воздух

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = jump_velocity
	if Input.is_action_pressed("shift"):
		speed = base_speed * run_multiplier
	else:
		speed = base_speed
	var raw_dir = Input.get_vector("a","d","w","s")
	var dir = (transform.basis * Vector3(raw_dir.x, 0, raw_dir.y)).normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
	if event.is_action_pressed("lmb"):
		if wm != null and raycast.is_colliding() and raycast.get_collider() is Sector:
			# Передаем 0 как ID блока -> функция поймет, что это разрушение
			wm.set_block_global(
				raycast.get_collider(), 
				raycast.get_collision_point(), 
				raycast.get_collision_normal(), 
				0
			)
			
	elif event.is_action_pressed("rmb"):
		if wm != null and raycast.is_colliding() and raycast.get_collider() is Sector:
			# Передаем 1 (или ID выбранного блока) -> функция поймет, что это установка
			wm.set_block_global(
				raycast.get_collider(), 
				raycast.get_collision_point(), 
				raycast.get_collision_normal(), 
				1 
			)
