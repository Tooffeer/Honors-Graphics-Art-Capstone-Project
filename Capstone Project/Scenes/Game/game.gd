extends Node

func _unhandled_input(_event):
	# Quit game
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
