extends Node3D

@onready var WM : WorldManager = $WorldManager

func _ready() -> void:
	WM.generate(0,0,0,10,3,10)
	
