extends CharacterBody3D

@onready var pivot = $Pivot
@onready var spring_arm_3d = $Pivot/SpringArm3D
@onready var model = $CollisionShape3D/Target
@onready var animation_tree = $AnimationTree


enum {IDLE, RUN}
var curAnim = IDLE
var value = 0

# Camera variables
@export var verCamSensitivity : float  = 0.04
@export var horCamSensitivity : float = 0.062

# Movement variables
@export var moveSpeed : float = 7.5
@export var accel : float = 14
@export var deaccel : float = 8.5
@export var airAccel : float = 5.2
@export var airDeaccel : float = 0.3
var ACCEL = accel
var DEACCEL = accel

# Jumping variables
@export var jumpHeight : float = 2.3
@export var timeToPeak : float = 0.36
@export var timeToFall: float = 0.32
@export var coyoteTime : float = 0.22
var coyoteTimer : float = 0.0
var canJump : bool = true

func _ready():
	Global.setPlayerNode(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Runs every physics frame
func _physics_process(delta):
	# Get input and direction based off camera
	var input_axis = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (pivot.basis * Vector3(input_axis.x, 0, input_axis.y)).normalized()
	
	
	print (input_axis)
	# Determine which accceleration to use
	if is_on_floor():
		ACCEL = accel
		DEACCEL = deaccel
	else:
		ACCEL = airAccel
		DEACCEL = airDeaccel
	
	camera()
	
	# Vertical movement
	if direction:
		velocity.x = direction.x * moveSpeed
		velocity.z = direction.z * moveSpeed
		curAnim = RUN
		#velocity.x += direction.x * ACCEL * delta
		#velocity.z += direction.z * ACCEL * delta
	else:
		velocity.x = move_toward(velocity.x, 0, 1)
		velocity.z = move_toward(velocity.z, 0, 1)
		curAnim = IDLE
		#velocity.x -= velocity.x * DEACCEL * delta
		#velocity.z -= velocity.z * DEACCEL * delta
	
	# Limit velocity
	#velocity.x = clamp(velocity.x, -moveSpeed, moveSpeed)
	#velocity.z = clamp(velocity.z, -moveSpeed, moveSpeed)
	
	jump(delta, direction)
	
	move_and_slide()
	
	match curAnim:
		IDLE:
			value = lerpf(value, 0, 15 * delta)
		RUN:
			value = lerpf(value, 1, 15 * delta)
	
	animation()
	model.rotation.y = atan2(velocity.x, velocity.z)

# Camera rotation
func camera():
	var input_axis = -Input.get_vector("Camera Left", "Camera Right", "Camera Down", "Camera Up")
	pivot.rotate_y(input_axis.x * horCamSensitivity)
	spring_arm_3d.rotate_x(input_axis.y * verCamSensitivity)
	spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, deg_to_rad(-45), deg_to_rad(40))

# "Building a Better Jump" - J. Kyle Pittman
func jump(delta, direction):
	var jumpVelocity : float = (2.0 * jumpHeight) / timeToPeak
	var jumpGravity : float = -(2.0 * jumpHeight) / pow(timeToPeak, 2.0)
	var fallGravity : float = -(2.0 * jumpHeight) / pow(timeToFall, 2.0)
	
	if not is_on_floor():
		# Apply gravity
		velocity.y += getGravity(jumpGravity, fallGravity) * delta
		# Start coyote timer
		coyoteTimer += delta
	else:
		# Reset coyote timer
		coyoteTimer = 0.0
		canJump = true
	
	# Jump
	if Input.is_action_pressed("Jump") and canJump and coyoteTimer <= coyoteTime:
		velocity.y = jumpVelocity
		canJump = false
	
	# Dive
	#if Input.is_action_just_pressed("Dive"):
		#velocity.y = jumpVelocity/2
		#velocity.x = 200 * direction.x
		#velocity.z = 200 * direction.z

# Determine gravity
func getGravity(jumpGravity, fallGravity):
	if velocity.y > 0.0: 
		return jumpGravity
	else:
		return fallGravity

func animation():
	animation_tree["parameters/Blend2/blend_amount"] = value
