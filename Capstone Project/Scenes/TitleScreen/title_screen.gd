extends Control

func _ready():
	$Options/Start.grab_focus()

func _on_start_pressed():
	Global.emit_signal("startGame")
	visible = false

func _on_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_quit_pressed():
	get_tree().quit()
