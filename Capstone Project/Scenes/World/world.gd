extends Node3D
@onready var environment = $Lighting/WorldEnvironment.environment
@onready var gate = $Gate



var gateState : bool = false

var density = 0.0
var light = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	environment.volumetric_fog_enabled = false
	density = 0.0
	light = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	environment.volumetric_fog_density = density
	$Lighting/DirectionalLight3D.light_energy = light
	
	if Global.collectables >= Global.goal:
		# open gate
		if !gateState:
			gateState = true
			gate.hide()
			$Gate/CollisionShape3D.disabled = true
		
		# start fog
		environment.volumetric_fog_enabled = true
		density = move_toward(density, 0.13, 0.25 * delta)
		light = move_toward(light, 0.0, delta)
