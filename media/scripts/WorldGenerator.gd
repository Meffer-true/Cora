extends RefCounted
class_name WorldGenerator

var data : GenerationData
var noise : FastNoiseLite

func _init() -> void:
	noise = FastNoiseLite.new()
