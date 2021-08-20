extends Area2D

signal pressed

var speed = gv.button_speed
var dir = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("input_event", self, "_input")

func _input(event):
	if event is InputEventMouseButton and event.pressed == true:
		emit_signal("pressed", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x += dir * speed * delta
