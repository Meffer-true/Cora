extends Node3D

@onready var WM : WorldManager = $WorldManager

@export var block : BlockData

func _ready() -> void:
	WM.generate(0,0,0,3,1,3,1)
	WM.generate(0,-1,0,3,-2,3,2)
	pass
