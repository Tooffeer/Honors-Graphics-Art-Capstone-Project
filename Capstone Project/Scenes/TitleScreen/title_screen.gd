extends Control

func _ready():
	$Options/Start.grab_focus()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	$"Mr_ Mackinley/AnimationPlayer".play("Idle")

func _on_start_pressed():
	Global.emit_signal("startGame")
	visible = false
	
	$"Mr_ Mackinley".queue_free()
	$WorldEnvironment.queue_free()
	$DirectionalLight3D.queue_free()

func _on_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_quit_pressed():
	get_tree().quit()
