extends Node3D

@onready var WM : WorldManager = $WorldManager

func _ready() -> void:
	WM.generate(0,0,0,2,1,1,1)
	WM.generate(0,1,0,2,2,1,1)
	
