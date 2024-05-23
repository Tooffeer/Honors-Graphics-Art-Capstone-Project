extends CharacterBody3D

@onready var pivot = $Pivot
@onready var spring_arm_3d = $Pivot/SpringArm3D
@onready var model = $CollisionShape3D/Target
@onready var animation_tree = $AnimationTree

# Movement
@export var moveSpeed : float = 7.5
@export var accel : float = 14
@export var deaccel : float = 8.5
@export var airAccel : float = 5.2
@export var airDeaccel : float = 0.3
var ACCEL = accel
var DEACCEL = accel

# Jumping
@export var jumpHeight : float = 2.3
@export var timeToPeak : float = 0.36
@export var timeToFall: float = 0.32
@export var coyoteTime : float = 0.22
var coyoteTimer : float = 0.0
var canJump : bool = true

# Camera
@export var verCamSensitivity : float  = 0.04
@export var horCamSensitivity : float = 0.062

# Animation
enum {IDLE, RUN}
var curAnim = IDLE
var value = 0


func _ready():
	# Set reference to global
	Global.setPlayerNode(self)
	# Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Need to fix this crap
	
	
	# Get input and direction based off of camera
	var input_axis = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (pivot.basis * Vector3(input_axis.x, 0, input_axis.y))
	
	print(input_axis.normalized())
	print(direction.normalized())
	# Determine accceleration
	if is_on_floor():
		ACCEL = accel
		DEACCEL = deaccel
	else:
		ACCEL = airAccel
		DEACCEL = airDeaccel
	
	# Vertical movement
	if direction:
		velocity.x = direction.x * moveSpeed
		velocity.z = direction.z * moveSpeed
		
		#velocity.x += direction.x * ACCEL * delta
		#velocity.z += direction.z * ACCEL * delta
		curAnim = RUN
		model.rotation.y = atan2(velocity.x, velocity.z)
	else:
		velocity.x = move_toward(velocity.x, direction.x, moveSpeed)
		velocity.z = move_toward(velocity.z, direction.z, moveSpeed)
		
		velocity.x -= velocity.x * DEACCEL * delta
		velocity.z -= velocity.z * DEACCEL * delta
		curAnim = IDLE
	
	
	velocity.x = clamp(velocity.x, -moveSpeed, moveSpeed)
	velocity.z = clamp(velocity.z, -moveSpeed, moveSpeed)
	
	var test = Vector2(velocity.x, velocity.z)
	if test.length() >= moveSpeed:
		velocity.x = velocity.normalized().x * moveSpeed
		velocity.z = velocity.normalized().z * moveSpeed
	
	print(velocity.length())
	
	
	
	
	
	
	jump(delta)
	
	move_and_slide()
	camera()
	
	# Testing animation
	match curAnim:
		IDLE:
			value = lerpf(value, 0, 15 * delta)
		RUN:
			value = lerpf(value, 1 * direction.length(), 15 * delta)
	
	animation()

func camera():
	var input_axis = Input.get_vector("Camera Right", "Camera Left", "Camera Down", "Camera Up")
	pivot.rotate_y(input_axis.x * horCamSensitivity)
	spring_arm_3d.rotate_x(input_axis.y * verCamSensitivity)
	spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, deg_to_rad(-45), deg_to_rad(40))

func jump(delta):
	# "Building a Better Jump" - J. Kyle Pittman
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

func getGravity(jumpGravity, fallGravity):
	if velocity.y > 0.0: 
		return jumpGravity
	else:
		return fallGravity

func animation():
	animation_tree["parameters/Blend2/blend_amount"] = value
