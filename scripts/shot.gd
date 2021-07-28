extends Area2D

signal shield_hit(type)
signal line_hit(type)

var shot_tex1 = preload("res://sprites/shot_health.png")

#var rng = RandomNumberGenerator.new()

var velocity = gv.velocity

var main

var type 

# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_tree().root.get_child(0)
	type = self.get_node("type").editor_description
	#rng.randomize()
	connect("area_entered", self, "_hit")
	
	
func _process(delta):
	self.position.y += velocity

func _hit(area):
	if "shield" in area.name:
		gv.score += 2
		queue_free()
	elif "line" in area.name:
		if type == "normal":
			if gv.score-1 < 0:
				gv.score = 0
			else: gv.score -= 1
		elif type == "bomb":
			if gv.score-10 < 0:
				gv.score = 0
			else: gv.score -= 10
		queue_free()
	else: pass
			
