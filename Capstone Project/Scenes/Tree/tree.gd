extends Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	frame = 0
	var x = randi() % 2
	if x:
		flip_h = true
	else:
		flip_h = false

func _process(_delta):
	if Global.collectables >= Global.goal:
		frame = 1
