extends Node

var Breg : BlockRegistry

func _ready() -> void:
	Breg = BlockRegistry.new()
	var blocks = Breg.read_folder("C:/Users/user/Desktop/blocks")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("f11"):
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			_:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
