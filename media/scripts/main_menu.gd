extends Control

var t : float = 1
var current_panel 

var card = preload("res://media/scenes/pack_card.tscn")

func _ready() -> void:
	global.im_here(self)

func _process(delta: float) -> void:
	smth_cube(delta)

func smth_cube(delta: float) -> void:
	t += delta 
	$cool_scene/cube.get_active_material(0).emission_energy_multiplier = 0.5 * (1.0 + sin(t) * cos(t * 0.5))
	$SubViewport/neck.rotation.y += 0.001

func add_pack_card(name : StringName):
	print("Добавляем карточку.")
	var card_i = card.instantiate()
	card_i.pack_name = name
	$packs_panel/packs_list.add_child(card_i)

func _on_play_button_pressed() -> void:
	current_panel = $play_panel
	$side_panel.visible = false; $play_panel.visible = true


func _on_settings_button_pressed() -> void:
	current_panel = $settings_panel
	$side_panel.visible = false; $settings_panel.visible = true


func _on_packs_button_pressed() -> void:
	current_panel = $packs_panel
	$side_panel.visible = false; $packs_panel.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	$side_panel.visible = true; current_panel.visible = false
	current_panel = $side_panel


func _on_general_button_pressed() -> void:
	pass # Replace with function body.


func _on_video_button_pressed() -> void:
	pass # Replace with function body.


func _on_audio_button_pressed() -> void:
	pass # Replace with function body.


func _on_input_button_pressed() -> void:
	pass # Replace with function body.


func _on_other_button_pressed() -> void:
	pass # Replace with function body.
