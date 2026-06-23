extends Node

var Breg : BlockRegistry

func _ready() -> void:
	Breg = BlockRegistry.new()
	var blocks = Breg.read_folder("C:/Users/user/Desktop/blocks")
	
