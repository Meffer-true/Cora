extends Control

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

func _process(delta: float) -> void:
	t+=delta
	match $incpector_window/DEV_state_choosing_button.selected:
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


func _on_next_button_pressed() -> void:
	Global.inspector_done(0)
