extends CharacterBody3D

@onready var pivot = $Pivot
@onready var spring_arm_3d = $Pivot/SpringArm3D
@onready var model = $CollisionShape3D/Target
@onready var animation_tree = $AnimationTree
@onready var particles = $CPUParticles3D

# Camera
@export var verCamSensitivity : float  = 0.04
@export var horCamSensitivity : float = 0.062

# Movement
@export var moveSpeed : float = 7.5
@export var accel : float = 14
@export var deaccel : float = 8.5
@export var airAccel : float = 5.2
@export var airDeaccel : float = 0.3
var ACCEL = accel
var DEACCEL = accel

# Jumping
@export var jumpHeight : float = 4.6
@export var timeToPeak : float = 0.37
@export var timeToFall: float = 0.31
@export var coyoteTime : float = 0.14
var coyoteTimer : float = 0.0
var canJump : bool = true

# Animation
enum {IDLE, RUN, FALL, RISE}
var curAnim = IDLE
var value = 0
var value2 = 0
var value3 = 0

func _ready():
	# Set reference to global
	Global.setPlayerNode(self)
	# Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Get input and direction based off of camera
	var input_axis = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (pivot.basis * Vector3(input_axis.x, 0, input_axis.y))
	
	# Determine accceleration
	if is_on_floor():
		ACCEL = accel
		DEACCEL = deaccel
		
		if Vector3(-velocity.x, 0, -velocity.z).length() >= moveSpeed - 2:
			particles.emitting = true
		else:
			particles.emitting = false
	else:
		ACCEL = airAccel
		DEACCEL = airDeaccel
		particles.emitting = false
	
	# Vertical movement
	if direction:
		velocity.x = lerp(velocity.x, moveSpeed * direction.x, ACCEL * delta)
		velocity.z = lerp(velocity.z, moveSpeed * direction.z, ACCEL * delta)
		
		# Rotate mesh to face direction
		model.rotation.y = atan2(velocity.x, velocity.z)
		particles.rotation.y = atan2(velocity.x, velocity.z)
	else:
		velocity.x = lerp(velocity.x, direction.x, DEACCEL * delta)
		velocity.z = lerp(velocity.z, direction.z, DEACCEL * delta)
		
	
	
	velocity.x = clamp(velocity.x, -moveSpeed, moveSpeed)
	velocity.z = clamp(velocity.z, -moveSpeed, moveSpeed)
	
	var test = Vector2(velocity.x, velocity.z)
	if test.length() >= moveSpeed:
		velocity.x = velocity.normalized().x * moveSpeed
		velocity.z = velocity.normalized().z * moveSpeed
	
	jump(delta)
	camera()
	move_and_slide()
	
	# Figure out animation
	if velocity.y > 0:
		curAnim = RISE
	elif velocity.y < 0:
		curAnim = FALL
	elif direction and velocity.y == 0:
		curAnim = RUN
	else:
		curAnim = IDLE
	
	# Testing animation
	match curAnim:
		IDLE:
			value = lerpf(value, 0, 15 * delta)
			value3 = lerpf(value3, 0, 15 * delta)
		RUN:
			value = lerpf(value, 1 * direction.length(), 15 * delta)
			value3 = lerpf(value3, 0, 15 * delta)
		FALL:
			value2 = lerpf(value2, 0, 15 * delta)
			value3 = lerpf(value3, 1, 8 * delta)
		RISE:
			value2 = lerpf(value2, 1, 15 * delta)
			value3 = lerpf(value3, 1, 8 * delta)
	
	animation()
	

func camera():
	var input_axis = Input.get_vector("Camera Right", "Camera Left", "Camera Down", "Camera Up")
	pivot.rotate_y(input_axis.x * horCamSensitivity)
	spring_arm_3d.rotate_x(input_axis.y * verCamSensitivity)
	spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, deg_to_rad(-70), deg_to_rad(40))

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
	if Input.is_action_just_pressed("Jump") and canJump and coyoteTimer <= coyoteTime:
		velocity.y = jumpVelocity
		canJump = false
		
		$JumpSound.play()

func getGravity(jumpGravity, fallGravity):
	if velocity.y > 0.0: 
		return jumpGravity
	else:
		return fallGravity

func animation():
	animation_tree["parameters/Blend1/blend_amount"] = value
	animation_tree["parameters/Blend2/blend_amount"] = value2
	animation_tree["parameters/Blend3/blend_amount"] = value3
