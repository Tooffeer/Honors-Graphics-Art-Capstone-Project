extends Node3D
@export_node_path("MeshInstance3D") var followTarget

var target : Node
var update = false
var previousFrame : Transform3D
var currentFrame : Transform3D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Seperates this nodes transforms from it's parent.
	top_level = true
	# Sets a target to copy transforms from.
	target = get_parent()
	global_transform = target.global_transform
	
	update_transform()

# Called every frame.
func _process(_delta):
	if update:
		update_transform()
		update = false
	
	# Averages the transforms from the previous and current physics frames.
	var f = clamp(Engine.get_physics_interpolation_fraction(), 0, 1)
	global_transform = previousFrame.interpolate_with(currentFrame, f)

# Called every physics frame (60fps).
func _physics_process(_delta):
	update = true

# Updates the values for previous and current frames.
func update_transform():
	previousFrame = currentFrame
	currentFrame = target.global_transform


# Code used from https://youtu.be/gL0iibY6-Fg?si=Q903PghgS8jhoMG1 by "devmar"
