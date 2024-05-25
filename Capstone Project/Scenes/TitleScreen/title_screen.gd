extends Control

func _ready():
	$Options/Start.grab_focus()

func _on_start_pressed():
	Global.emit_signal("startGame")
	visible = false

func _on_quit_pressed():
	get_tree().quit()

func _process(_delta):
	if $Options/Fullscreen.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	#print(DisplayServer.window_get_size())
