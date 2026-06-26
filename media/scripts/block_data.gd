extends Resource
class_name BlockData

@export var name : StringName
@export var id : StringName
@export var color : Color

func _init() -> void:
	name = ""
	id = ""
	color = Color.WHITE
