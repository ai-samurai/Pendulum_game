extends Area2D

signal shield_hit(type)
signal line_hit(type)

var shot_tex1 = preload("res://sprites/shot_health.png")

var rng = RandomNumberGenerator.new()

var velocity = 6
var types = {0:"normal", 1:"health", 2: "bonus", 3: "speed", 4: "bomb", 5: "critical"}
var type_keys = types.keys()
var types_weighted = [0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5]
var type_index
var type_name
var action
var main

# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_tree().root.get_child(0)
	rng.randomize()
	type_index = types_weighted[randi() % types_weighted.size()]
	type_name = types[type_index]
	if type_index == 4 or type_index == 5:
		velocity = 2.5
	connect("area_entered" , self, "_hit")
	set_tex(type_name)
	

func set_tex(type):
	$Sprite.set_texture(load("res://sprites/shot_"+type+".png"))

func _process(delta):
	self.position.y += velocity

func _hit(area):
	if "shield" in area.name:
		emit_signal("shield_hit", type_index)
		queue_free()
	elif "line" in area.name:
		emit_signal("line_hit", type_index)
		queue_free()
	else: pass
			
