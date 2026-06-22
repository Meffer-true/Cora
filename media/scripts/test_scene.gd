extends Node3D

@onready var WM : WorldManager = $WorldManager

@export var block : BlockData

func _ready() -> void:
	WM.generate(-20,1,-20,20,5,20,1)
	
