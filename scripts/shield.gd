extends Area2D

var timer
var shield_time = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(shield_time)
	add_child(timer)
	timer.connect("timeout", self, "_on_timer_complete")
	timer.start()

func _on_timer_complete():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
