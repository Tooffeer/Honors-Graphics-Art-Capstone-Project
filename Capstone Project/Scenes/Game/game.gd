extends Node
var levelScene = preload("res://Scenes/World/world.tscn").instantiate()
var playerScene = preload("res://Scenes/Player3D/player_3d.tscn").instantiate()

func _ready():
	Global.connect("startGame", start)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func start():
	self.add_child(levelScene)
	self.add_child(playerScene)
