extends Node

var inspector_ready : bool = false

var game_path : String:
	set(v):
		print("Новая директория контента: " + str(v))
var Reg : Registry

var main_menu : Node
var inspector : Node

func _ready() -> void:
	print("Глобал запущен.")
	
	

func im_here(me:Node, message = 0):
	match me.get_meta("type"):
		"menu":
			main_menu = me
			for i in Reg.Packs:
				me.add_pack_card(i.pack_name)
		"inspector":
			print("inspector")
			inspector = me
			me.boot()
			me.boot_ready.connect(func():
				print("Принято, передаю папку Реестру.")
				Reg = Registry.new()
				Reg.path = game_path
				Reg.scan_folder()
				)
	

	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("f11"):
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			_:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
