extends Control

var t : float = 1

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	smth_cube(delta)

func smth_cube(delta: float) -> void:
	t += delta 
	$cool_scene/cube.get_active_material(0).emission_energy_multiplier = 0.5 * (1.0 + sin(t) * cos(t * 0.5))
	$SubViewport/neck.rotation.y += 0.001


func _on_play_button_pressed() -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	$side_panel.visible = false; $settings_panel.visible = true


func _on_packs_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	$side_panel.visible = true; $settings_panel.visible = false
