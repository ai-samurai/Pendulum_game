extends Area2D

signal pressed

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("input_event", self, "_input")

func _input(event):
	if event is InputEventMouseButton and event.pressed == true:
		emit_signal("pressed", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
