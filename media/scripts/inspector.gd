extends Control

signal boot_ready

var t : float

var current_state : state = state.VALID
enum state {
	VALID,
	WARNING,
	CRITICAL
}
var base_color : Color
var brightness : float

@onready var bkg = $background_rect

func _ready() -> void:
	current_state = state.VALID
	Global.im_here(self)

func _process(delta: float) -> void:
	t+=delta
	match $inspector_window/DEV_state_choosing_button.selected:
		0: current_state = state.VALID
		1: current_state = state.WARNING
		2: current_state = state.CRITICAL
	match current_state:
		state.VALID:
			base_color = Color.GRAY
			bkg.material.set_shader_parameter("liquid_speed", 0.5)
		state.WARNING:
			base_color = Color.GOLD
			bkg.material.set_shader_parameter("liquid_speed", 1)
		state.CRITICAL:
			base_color = Color.RED
			bkg.material.set_shader_parameter("liquid_speed", 2)
	brightness = remap(sin(t),-1,1,0.75,1.0)
	#bkg.material.set_shader_parameter("brightness", brightness)
	bkg.material.set_shader_parameter("base_color", base_color)
	bkg.material.set_shader_parameter("highlight_color", base_color.darkened(remap(sin(t),-1,1,0.1,0.2)))

func boot() -> void:
	print("boot")
	var config = ConfigFile.new()
	var boot_path: String
	if !OS.has_feature("editor"):
		boot_path = OS.get_executable_path().get_base_dir() + "/boot.ini"
	else:
		boot_path = "res://boot.ini"
	if FileAccess.file_exists(boot_path):
		var error = config.load(boot_path) 
		if error == OK:
			print('1')
			Global.game_path = config.get_value("Main","game_path")
			boot_ready.emit()
		else:
			print("Файл не может быть открыт.")
	else:
		print("Файла не существует. Создаем стандартный.")
		$inspector_window/set_path_form.popup_centered()
		$inspector_window/set_path_form/confirm_button.pressed.connect(func():$inspector_window/set_path_form.visible = false) # Подключаем функцию закрытия окошка по нажатию кнопки.
		await get_tree().create_timer(1.0).timeout
		$inspector_window/set_path_form/FileDialog.popup_centered()
		var new_path
		$inspector_window/set_path_form/FileDialog.dir_selected.connect(func(dir_path):
			Global.game_path = dir_path
			$inspector_window/set_path_form/path_text.text = str(dir_path)
			config.set_value("Main","game_path",dir_path)
			var save_err = config.save(boot_path)
			if save_err == OK:
				print("boot.ini успешно сохранен.")
				boot_ready.emit()
			else:
				print("Нам всем пиздец.")
			)
		

func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://media/scenes/main_menu.tscn")
