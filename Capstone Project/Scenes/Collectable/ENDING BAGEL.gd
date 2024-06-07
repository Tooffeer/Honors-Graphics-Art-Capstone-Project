extends Node3D
@onready var audio = $AudioStreamPlayer
@onready var mesh = $Bagel
var rotSpeed = 1.4

var collected = false

func _ready():
	mesh.rotate_y(randf_range(0, 180))

func _physics_process(delta):
	mesh.rotate_y(rotSpeed * delta)

# When collected
func _on_area_3d_body_entered(body):
	if body.is_in_group("player") and !collected:
		collected = true
		# Add to score
		Global.collectables += 1
		# Play sound
		audio.play()
		mesh.hide()
		
		Global.emit_signal("gameOver")
		
		# Die
		self.queue_free()

