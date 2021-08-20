extends Node2D

export (NodePath) var ui_label_value_path

onready var shot = load("res://Objects/shot.tscn")
onready var shield = load("res://Objects/shield2.tscn")

onready var ui_label_value = get_node(ui_label_value_path)

var shots
var shots_index = []
# to track on which side of pendulum was last shot created. -1 is for left side
# and +1 is for right side
var shot_dir = -1 
var shot_interval # timer to control the interval between successive shots

var shield_allowed = true # boolean to control shield availability

var shield_timer_cooldown # timer for shield_cooldown_time
var block_shield_timer # timer for block_shield_time

var shield_load_rate = 1 # to allow other shield cooldown rates in the future
var shield_load = 0 # to calculate shields generated in quick succession
var sb # shield bar, to show shield availability
var bt # button
var p # pendulum
var l # line
var score_label # score label
var lives_label # player lives label
var bt_extents # to store the shape of button node
var screen_size # size of visible screen


var left_shot_count = 0 # to stop score increase after x captures on left 
var right_shot_count = 0 # to stop score increase after x captures on right

var block_cooldown # timer to control block movement

var rng = RandomNumberGenerator.new()

var stop_shield = false # stop another shield from being genereated when one 
#	already present
var sb_color # to change the color of the shield bar, when block_shield = true



# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	shots = gv.shot_scenes
	#gv.velocity = gv.default_velocity
	for i in range(shots.size()):
		shots_index.push_back(i)

	sb = self.get_node("sb")
	bt = self.get_node("button")
	p = self.get_node("pendulum")
	l = self.get_node("line")
	score_label = self.get_node("score_label")
	lives_label = self.get_node("lives_label")
	bt.position = gv.bt_pos
	bt_extents = bt.get_node("CollisionShape2D").shape.extents * bt.scale
	screen_size = Vector2(get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y)
	
	# starts when a shield is created
	shield_timer_cooldown = add_timer("timer_pause", gv.shield_cooldown_time, "_on_cooldown_timeout_complete")
	
	# starts when too many shields created in a finite period (shield_limit)
	block_shield_timer = add_timer("block_shield_timer", gv.block_shield_time, "_on_block_shield_timeout_complete")
	
	self.get_node("button").connect("area_entered", self, "button_hit")
	block_cooldown = add_timer("block_timer", gv.block_cooldown_time, "_on_block_cooldown_timeout_complete")
	block_cooldown.start()
	
	
	shot_interval = add_timer("shot_interval", gv.shot_interval, "_on_shot_interval_timeout_complete", false)
	shot_interval.start()
	gv.connect("shot_interval_changed", self, "_on_shot_interval_changed")
	# shield bar color
	sb_color = sb.get("custom_styles/bg")
	sb_color.bg_color = Color(255, 255, 255)
	#print(sb_color)

# add a timer to the main_scene
func add_timer(timer_name, time, timer_function, one_shot=true):
	var timer = Timer.new()
	timer.set_one_shot(one_shot)
	timer.set_wait_time(time)
	add_child(timer)
	timer.name = timer_name
	timer.connect("timeout", self, timer_function)
	return timer


func _on_shot_interval_changed():
	shot_interval.set_wait_time(gv.shot_interval)

# on shot interval completion
func _on_shot_interval_timeout_complete():
	shot_dir = -1 * shot_dir
	create_shot()
	
# create shot at random times
func create_shot():
	var xpos = (shot_dir * gv.gap) + p.position.x
	var new_shot = gv.pick_shot().instance()
	new_shot.position = Vector2(xpos, p.position.y + 50)
	add_child(new_shot)
#	print(gv.velocity)
		

# to do when shot hits button
func button_hit(node):
	#bt_life -= 1
	if gv.lives == 0:
		get_tree().change_scene("game over.tscn")
	

# add new shield to main scene
func add_shield():
	var pos = Vector2(bt.position.x, bt.position.y - 170)
	var new_shield 
	new_shield = shield.instance()
	new_shield.position = pos
	new_shield.name = "shield"
	add_child(new_shield)
	self.get_node(new_shield.name).connect("area_entered", self, "shield_hit")
	
	
# set allow shields to true, part of process stop player from spamming shields
func _on_cooldown_timeout_complete():
	shield_load -= shield_load_rate
	if shield_load > 0:
		shield_timer_cooldown.start()
		
# to allow shields to be generated once block_shield_timer is complete
func _on_block_shield_timeout_complete():
	stop_shield = false
	sb_color.bg_color = Color(255, 255, 255)
	

func sig(x, n, c):
	var fx = float((pow(x,c))/(pow(n,(c-1))))
	#print(x)
	if x < 0.5: return fx + 0.2
	elif x < 1: return (0.2 + (1 - (float( (pow((1-x),c))/(pow((1-n),(c-1))) ))))
	else: return 1.2


func _process(delta):
	gv.velocity = gv.max_velocity * sig((float(gv.score)/float(gv.max_speed_score)), 0.5, 1.5)
	print(gv.velocity)
	if gv.lives <= 0:
		get_tree().change_scene("game over.tscn")
	# do not allow shields to be generated if # of shields generated is greater
	# 	than the shield limit, in a finite period. 
	if shield_load >= gv.shield_limit:
		shield_allowed = false
		block_shield_timer.start()
		stop_shield = true
		sb_color.bg_color = Color(255, 0, 0)
	# stop shield from being generated
	elif shield_load < gv.shield_limit and stop_shield == true and shield_load != 0:
		shield_allowed = false
	# allow shields to be generated once shield load is reduced to 0
	elif shield_load == 0 and stop_shield == false:
		shield_allowed = true
	sb.value = float(shield_load/3.0) * 100

	# change direction of button if out of extents
	if bt.position.x < bt_extents[0]:
		bt.dir = 1
	elif bt.position.x > screen_size[0] - bt_extents[0]:
		bt.dir = -1
	else: pass
	
	score_label.text = "Score: " + str(gv.score)
	lives_label.text = "Lives: " + str(gv.lives)
	

# when input is given to move block
func _input(event):
	if event.is_action_pressed("ui_left"):
		if bt.position.x - bt_extents[0] > 0 and bt.dir == 1:
			bt.dir = -1
		else: pass
	if event.is_action_pressed("ui_right"):
		if bt.position.x + bt_extents[0] < screen_size[0]:
			bt.dir = 1
		else: pass
		
	# to create shield if space is pressed and start shield cooldown
	if event.is_action_pressed("ui_select"):
		if shield_allowed == true:
			add_shield()
			shield_timer_cooldown.start()
			shield_load += shield_load_rate
		if shield_allowed == false:
			pass


	
