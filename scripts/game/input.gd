extends Node
class_name PlayerInput

# Inputs
var input_movement = Vector2.ZERO
var input_mouse = Vector2.ZERO

# Extra Variables
var last_input_mouse = Vector2.ZERO


func _ready():
	NetworkTime.before_tick_loop.connect(_gather)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _gather():
	if not is_multiplayer_authority():
		return
	
	# WASD
	input_movement = Input.get_vector("Left", "Right", "Forward", "Backward")
	# Mouse
	if not input_mouse == last_input_mouse:
		input_mouse = input_mouse # -event.relative
	else:
		input_mouse = Vector2.ZERO
	last_input_mouse = input_mouse


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion:
		input_mouse = -event.relative
		
