extends Node3D

# When collected
func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		Global.collectables += 1
		self.queue_free()
