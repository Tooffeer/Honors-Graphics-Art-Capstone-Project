extends CanvasLayer
@onready var counter = $HBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	updateInfo()

func _process(_delta):
	updateInfo()

func updateInfo():
	counter.text = "X " + str(Global.collectables)
