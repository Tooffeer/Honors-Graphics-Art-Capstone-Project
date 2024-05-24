extends Control

func _ready():
	$Options/Start.grab_focus()

func _on_start_pressed():
	Global.emit_signal("startGame")
	visible = false

func _on_quit_pressed():
	get_tree().quit()
