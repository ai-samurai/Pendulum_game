extends Area2D

var rot_speed = gv.ang_velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", self, "_on_area_entered")
	
	
func _on_area_entered(area):
	rot_speed = -rot_speed



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotation += rot_speed * delta
	

