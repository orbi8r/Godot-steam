extends CharacterBody3D


var SPEED = 5.0
var JUMP_VELOCITY = 4.5
var SENSITIVITY = 0.0006
var SPRINT_MULTIPLIER = 2

@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D


func _ready() -> void:
	camera_3d.current = is_multiplayer_authority()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera_3d.rotate_x(-event.relative.y * SENSITIVITY)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-40), deg_to_rad(80))


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Sprint Multiplier
	if Input.is_action_just_pressed("Sprint"):
		SPEED *= SPRINT_MULTIPLIER
		JUMP_VELOCITY *= SPRINT_MULTIPLIER
	elif Input.is_action_just_released("Sprint"):
		SPEED /= SPRINT_MULTIPLIER
		JUMP_VELOCITY /= SPRINT_MULTIPLIER
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
