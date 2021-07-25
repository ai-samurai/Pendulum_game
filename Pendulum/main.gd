extends Node2D

export (NodePath) var ui_label_value_path

onready var shot = load("res://Objects/shot.tscn")
onready var shield = load("res://Objects/shield2.tscn")
onready var ui_label_value = get_node(ui_label_value_path)

var shield_allowed = true
var shield_cooldown_time = 0.4 # amount of time a shield stays on main scene
var block_shield_time = 6 # timer for shield blocking after spamming
var shield_timer_cooldown # timer for shield_cooldown_time
var block_shield_timer # timer for block_shield_time
var shield_limit = 3 # number of shields that are allowed in quick succession
var shield_load_rate = 1 # to allow other shield cooldown rates in the future
var shield_load = 0 # to calculate shields generated in quick succession
var sb # shield bar
var b1 # block 1
var b2 # block 2
var bt # button
var p # pendulum
var l # line
var score_label # score label
var lives_label # player lives label
var bt_pos = Vector2(240, 750) # button position
var bt_life = 3 # button lives

var left_shot_count = 0 # to stop score increase after x captures on left 
var right_shot_count = 0 # to stop score increase after x captures on right
var score = 0

var block_cooldown
var block_cooldown_time = 2
var rng = RandomNumberGenerator.new()
var move_block = true
var block_speed = 2
var move_left = true
var move_right = true
var blocks = [1,2,3,3]
var choice
var block_shield = false
var sb_color # to change the color of the shield bar, when block_shield = true



# Called when the node enters the scene tree for the first time.
func _ready():
	sb = self.get_node("sb")
	b1 = self.get_node("block_1")
	b2 = self.get_node("block_2")
	bt = self.get_node("button")
	p = self.get_node("pendulum")
	l = self.get_node("line")
	score_label = self.get_node("score_label")
	lives_label = self.get_node("lives_label")
	bt.position = bt_pos
	
	# starts when a shield is created
	shield_timer_cooldown = add_timer("timer_pause", shield_cooldown_time, "_on_cooldown_timeout_complete")
	
	# starts when too many shields created in a finite period (shield_limit)
	block_shield_timer = add_timer("block_shield_timer", block_shield_time, "_on_block_shield_timeout_complete")
	
	self.get_node("pendulum").connect("area_entered" , self, "hit")
	self.get_node("button").connect("area_entered", self, "button_hit")
	block_cooldown = add_timer("block_timer", block_cooldown_time, "_on_block_cooldown_timeout_complete")
	block_cooldown.start()
	
	# shield bar color
	sb_color = sb.get("custom_styles/bg")
	sb_color.bg_color = Color(255, 255, 255)
	#print(sb_color)

# add a timer to the main_scene
func add_timer(timer_name, time, timer_function):
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(time)
	add_child(timer)
	timer.name = timer_name
	timer.connect("timeout", self, timer_function)
	return timer

# create shot when pendulum hits an area
func hit(area):
	var rand_dir = pow(-1, randi() % 2)
	var pos = Vector2(area.position.x + (rand_dir*20), bt.position.y - 450)
	var new_shot
	new_shot = shot.instance()
	new_shot.position = pos
	add_child(new_shot)
	#print(self.get_node(new_shot.name).type_name)
	self.get_node(new_shot.name).connect("shield_hit", self, "_shield_hit")
	self.get_node(new_shot.name).connect("line_hit", self, "_line_hit")

# to do when shot hits the shield, for various actions such as increasing lives,
#	bonus to score, increasing shot speed, decreasing lives
func _shield_hit(type):
	print(gv.mode)
	if type == 2:
		bt_life += 1

# to do when shot hits button
func button_hit(node):
	bt_life -= 1
	if bt_life == 0:
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
	
# to do when shield is hit with a shot, for counting score
func shield_hit(node):
	# check shot is from which side and increase shot count accordingly
	if node.position.x < 240:
		right_shot_count = 0
		if left_shot_count <= 2: 
			score += 1
			left_shot_count += 1
		else: pass
	else:
		left_shot_count = 0
		if right_shot_count <= 2: 
			score += 1
			right_shot_count += 1
		else: pass
	score_label.text = "Score: "+ str(score)
	
# set allow shields to true, part of process stop player from spamming shields
func _on_cooldown_timeout_complete():
	shield_load -= shield_load_rate
	if shield_load > 0:
		shield_timer_cooldown.start()
		
# to allow shields to be generated once block_shield_timer is complete
func _on_block_shield_timeout_complete():
	block_shield = false
	sb_color.bg_color = Color(255, 255, 255)
	

func _process(delta):
	# do not allow shields to be generated if # of shields generated is greater
	# 	than the shield limit, in a finite period. 
	if shield_load >= shield_limit:
		shield_allowed = false
		block_shield_timer.start()
		block_shield = true
		sb_color.bg_color = Color(255, 0, 0)
	# stop shield from being generated
	elif shield_load < shield_limit and block_shield == true and shield_load != 0:
		shield_allowed = false
	# allow shields to be generated once shield load is reduced to 0
	elif shield_load == 0 and block_shield == false:
		shield_allowed = true
	sb.value = float(shield_load/3.0) * 100

	if b1.position.x < 50:
		move_left = false
	if b1.position.x > 140:
		move_left = true
	if b2.position.x < 340:
		move_right = true
	if b2.position.x > 430:
		move_right = false
	
	if move_block == true:
		if choice == 1:
			move_block(b1)
		elif choice == 2:
			move_block(b2)
		elif choice == 3:
			move_block(b1)
			move_block(b2)
	else: pass
	
	lives_label.text = "Lives: " + str(bt_life)
	
# to create binary to feed into _on_block_cooldown_timeout_complete 
#	this is used to control the movement of the blocks. A lower probability 
#	of movement is assigned if blocks are closer.
func _block_stop():
	rng.randomize()
	var n = rng.randi_range(1, 10)
	if b2.position.x - b1.position.x > 300:
		if n < 1: return true
		else: return false
	elif b2.position.x - b1.position.x < 280:
		if n < 8: return true
		else: return false
	else:
		if n < 3: return true
		else: return false
	
# to signal block movement complete after block_cooldown
func _on_block_cooldown_timeout_complete():
	_block_movement(_block_stop())
	
	
# to start timer and start or stop block
func _block_movement(state):
	choice = blocks[randi() % blocks.size()]
	if state == true:
		move_block = false
		block_cooldown.start()
	if state == false:
		move_block = true
		block_cooldown.start()

# to move a block depending upon direction requirement
func move_block(block):
	if block == b1:
		if move_left == true:
			b1.position.x -= block_speed
		elif move_left == false:
			b1.position.x += block_speed
	if block == b2:
		if move_right == true:
			b2.position.x += block_speed
		elif move_right == false:
			b2.position.x -= block_speed

# when input is given to move block
func _input(event):
	if event.is_action_pressed("ui_left"):
		if bt.position.x > bt_pos.x - 120:
			bt.position.x -= 120
		else: pass
	if event.is_action_pressed("ui_right"):
		if bt.position.x < bt_pos.x + 120:
			bt.position.x += 120
		else: pass
		
	# to create shield if space is pressed and start shield cooldown
	if event.is_action_pressed("ui_select"):
		if shield_allowed == true:
			add_shield()
			shield_timer_cooldown.start()
			shield_load += shield_load_rate
		if shield_allowed == false:
			pass
