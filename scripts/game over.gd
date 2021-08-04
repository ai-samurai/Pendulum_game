extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_restartButton_pressed():
	print("restart button pressed")
	gv.score = 0
	gv.lives = 3
	get_tree().change_scene("res://main.tscn")


func _on_quitButton_pressed():
	get_tree().quit()
