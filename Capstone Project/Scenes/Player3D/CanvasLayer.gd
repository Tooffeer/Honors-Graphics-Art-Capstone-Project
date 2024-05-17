extends CanvasLayer

@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	updateInfo()

func _process(delta):
	updateInfo()

func updateInfo():
	label.text = "Collectables: " + str(Global.collectables)
