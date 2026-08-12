extends Resource
class_name GenerationData

@export var name : StringName

@export_group("Noise settings")
@export_range(0,99999,1.0) var seed : int
@export var base_height : int
@export var height_amplitude: float
@export var noise_frequency: float
@export var noise_octaves: int

@export_group("Levels")
@export var sea_level: int
@export var dirt_layer_thickness : int
