extends Node

var Reg : Registry

func _ready() -> void:
	print("Глобал запущен.")
	Reg = Registry.new()
	Reg.path = "res://export"
	Reg.scan_folder()

func im_here(menu):
	for i in Reg.Packs:
		menu.add_pack_card(i.pack_name)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("f11"):
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			_:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
