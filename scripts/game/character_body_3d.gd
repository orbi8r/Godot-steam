extends CharacterBody3D

var SPEED = 5.0
var JUMP_VELOCITY = 4.5
var SENSITIVITY = 0.0002
var SPRINT_MULTIPLIER = 1.5

@export var input: PlayerInput
@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var rollback_synchronizer: RollbackSynchronizer = $RollbackSynchronizer

var peer_id = 0


func _ready() -> void:
	camera_3d.current = is_multiplayer_authority()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().process_frame
	
	# Set owner
	peer_id = get_multiplayer_authority()
	set_multiplayer_authority(1)
	input.set_multiplayer_authority(peer_id)
	rollback_synchronizer.process_settings()


func _apply_movement_from_input(delta):
	if !is_multiplayer_authority():
		return
	
	_force_update_is_on_floor()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Mouse Movement
	head.rotate_y(input.input_mouse.x * SENSITIVITY * NetworkTime.physics_factor)
	camera_3d.rotate_x(input.input_mouse.y * SENSITIVITY * NetworkTime.physics_factor)
	camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-60), deg_to_rad(80))

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
	var input_dir = input.input_movement
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	# Converting Properties to acknowledge Network time
	velocity *= NetworkTime.physics_factor
	
	move_and_slide()
	
	# Converting Properties back
	velocity /= NetworkTime.physics_factor


func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector3.ZERO
	move_and_slide()
	velocity = old_velocity


func _rollback_tick(delta, tick, is_fresh):
	_apply_movement_from_input(delta)
