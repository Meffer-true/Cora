extends Node3D

var sector : Sector

func _ready() -> void:
	sector = Sector.new()
	sector.position = Vector3(0,3,0)
	add_child(sector)
	sector.test_generate()
	sector.update()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("r"):
		sector.update()
