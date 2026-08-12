extends Control

var t : float = 1
var current_panel 

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	smth_cube(delta)

func smth_cube(delta: float) -> void:
	t += delta 
	$cool_scene/cube.get_active_material(0).emission_energy_multiplier = 0.5 * (1.0 + sin(t) * cos(t * 0.5))
	$SubViewport/neck.rotation.y += 0.001


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
