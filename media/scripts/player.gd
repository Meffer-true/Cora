extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D

@export var speed : int = 10
@export var mouse_sensitivity : float = 0.002
@export var jump_velocity: float = 5.0

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = jump_velocity
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
