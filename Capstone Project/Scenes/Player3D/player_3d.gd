extends CharacterBody3D

@onready var pivot = $Pivot
@onready var spring_arm_3d = $Pivot/SpringArm3D

# Camera variables
var camSensitivity = 0.07

# Movement variables
@export var moveSpeed : float
@export var accel : float
@export var deaccel : float
@export var airAccel : float
@export var airDeaccel : float
var ACCEL = accel
var DEACCEL = accel

# Jumping variables
@export var jumpHeight : float
@export var timeToPeak : float
@export var timeToFall : float

# Runs every physics frame
func _physics_process(delta):
	camera()
	jump(delta)
	
	# Get input and direction based off camera
	var input_axis = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (pivot.basis * Vector3(input_axis.x, 0, input_axis.y)).normalized()
	
	# Determine which accceleration to use
	if is_on_floor():
		ACCEL = accel
		DEACCEL = deaccel
	else:
		ACCEL = airAccel
		DEACCEL = airDeaccel
	
	# Vertical movement
	if direction:
		velocity.x += direction.x * ACCEL * delta
		velocity.z += direction.z * ACCEL * delta
	else:
		velocity.x -= velocity.x * DEACCEL * delta
		velocity.z -= velocity.z * DEACCEL * delta
	
	# Limit velocity
	velocity.x = clamp(velocity.x, -moveSpeed, moveSpeed)
	velocity.z = clamp(velocity.z, -moveSpeed, moveSpeed)
	
	move_and_slide()

# Move camera
func camera():
	var input_axis = -Input.get_vector("Camera Left", "Camera Right", "Camera Down", "Camera Up")
	pivot.rotate_y(input_axis.x * camSensitivity)
	spring_arm_3d.rotate_x(input_axis.y * camSensitivity)
	
	# Stop camera from doing 360s
	spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, deg_to_rad(-75), deg_to_rad(50))

# "Building a Better Jump" - J. Kyle Pittman
func jump(delta):
	var jumpVelocity : float = (2.0 * jumpHeight) / timeToPeak
	var jumpGravity : float = -(2.0 * jumpHeight) / pow(timeToPeak, 2.0)
	var fallGravity : float = -(2.0 * jumpHeight) / pow(timeToFall, 2.0)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += getGravity(jumpGravity, fallGravity) * delta
	
	# Jumping
	if Input.is_action_just_pressed("Jump"):
		velocity.y = jumpVelocity

# Determine gravity
func getGravity(jumpGravity, fallGravity):
	if velocity.y > 0.0: 
		return jumpGravity
	else:
		return fallGravity

