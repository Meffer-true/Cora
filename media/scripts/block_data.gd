extends Resource
class_name BlockData

@export var name : String
@export var id : String
@export var color : Color

func _init() -> void:
	name = ""
	id = ""
	color = Color.WHITE
