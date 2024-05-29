extends Node

# Preload scenes
var levelScene = preload("res://Scenes/World/world.tscn").instantiate()
var playerScene = preload("res://Scenes/Player3D/player_3d.tscn").instantiate()

func _ready():
	Global.connect("startGame", start_game)

func _unhandled_input(_event):
	# Quick close, remove later
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func start_game():
	# Add scenes to tree
	self.add_child(levelScene)
	self.add_child(playerScene)
