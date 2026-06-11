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
	if get_node("../WorldManager") != null:
		wm = get_node("../WorldManager")
		print("WM is %s" % [wm])

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
		print("Замечен клик левой кнопки мыши.")
		if wm != null and raycast.get_collider() is Sector:
			print("WorldManager присутствует и коллайдер есть сектор.")
			var collision_point = raycast.get_collision_point()
			var collision_normal = raycast.get_collision_normal()
			var global_pos = Vector3i()
			global_pos.x = collision_point.x - (collision_normal.x * 0.001)
			global_pos.y = collision_point.y - (collision_normal.y * 0.001)
			global_pos.z = collision_point.z - (collision_normal.z * 0.001)
			wm.set_block_global(global_pos,1)
	elif event.is_action_pressed("rmb"):
		interact_with_voxel(true, 1)
