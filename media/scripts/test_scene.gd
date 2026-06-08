extends Node3D

func _ready() -> void:
	var sector = Sector.new()
	sector.position = Vector3(0,3,0)
	add_child(sector)
	sector.test_generate()
	sector.update()
	
