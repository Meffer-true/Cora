extends Node3D

@onready var WM : WorldManager = $WorldManager

@export var block : BlockData

func _ready() -> void:
	WM.generate(-1,-1,-1,1,1,1,0)
