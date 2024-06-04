extends Node3D

@onready var mesh = $MeshInstance3D

@export var rotSpeed = 1.4

# When collected
func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		Global.collectables += 1
		self.queue_free()

func _physics_process(delta):
	mesh.rotate_y(rotSpeed * delta)
