extends Area2D

var speed = gv.pendulum_velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", self, "_on_area_entered")
	
	
func _on_area_entered(area):
	speed = -speed



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x += speed * delta
	

