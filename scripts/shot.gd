extends Area2D

signal shield_hit(type)
signal line_hit(type)

var shot_tex1 = preload("res://sprites/shot_health.png")

#var rng = RandomNumberGenerator.new()

#var velocity = gv.velocity

var main

var type 

# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_tree().root.get_child(0)
	type = self.get_node("type").editor_description
	#rng.randomize()
	connect("area_entered", self, "_hit")
	
	
func _process(delta):
	self.position.y += gv.velocity
	
# if the shot enters another area
func _hit(area):
	if "shield" in area.name:
		if type == "normal":
			gv.score += 2
		elif type == "health":
			if gv.lives <= 9:
				gv.lives += 1
			else: pass
		elif type == "bonus":
			gv.score += 10
		elif type == "portal":
			print("hit portal")
			get_tree().change_scene("portal_scene.tscn")
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
		elif type == "critical":
			gv.lives -= 2
		queue_free()
	elif "button" in area.name:
		gv.lives -= 1
		queue_free()
	else: pass
			
