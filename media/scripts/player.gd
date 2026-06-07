extends CharacterBody3D

@export var speed : int = 10

func _physics_process(delta: float) -> void:
	var dir = Input.get_vector("a","d","w","s")
	velocity = Vector3(dir.x,0,dir.y) * speed
	move_and_slide()
