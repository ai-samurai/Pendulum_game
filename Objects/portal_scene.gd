extends Node2D

export (NodePath) var ui_label_value_path

onready var shot = load("res://Objects/shot.tscn")
onready var shield = load("res://Objects/shield2.tscn")

onready var ui_label_value = get_node(ui_label_value_path)

var shots
var shots_index = []

var shield_allowed = true # boolean to control shield availability

var shield_timer_cooldown # timer for shield_cooldown_time
var block_shield_timer # timer for block_shield_time

var shield_load_rate = 1 # to allow other shield cooldown rates in the future
var shield_load = 0 # to calculate shields generated in quick succession
var sb # shield bar, to show shield availability
var b1 # block 1
var b2 # block 2
var bt # button
var p # pendulum
var l # line
var score_label # score label
var lives_label # player lives label


var left_shot_count = 0 # to stop score increase after x captures on left 
var right_shot_count = 0 # to stop score increase after x captures on right

var block_cooldown # timer to control block movement
var portal_cooldown # timer to end portal scene

var rng = RandomNumberGenerator.new()
var move_block = true # binary to control movement of blocks

var move_left = true # binary to restrain block movement within desired range
var move_right = true # binary like move_left but for right side
var blocks = [1,2,3,3] # to control probability of which block/s should move
var choice # to store the return from blocks array random selection
var stop_shield = false # stop another shield from being genereated when one 
#	already present
var sb_color # to change the color of the shield bar, when block_shield = true
var shots_created = 0 # to track the number of shots created in the portal scene



# Called when the node enters the scene tree for the first time.
func _ready():
	#portal_cooldown = add_timer("portal_cooldown", gv.portal_cooldown_time, "_on_portal_cooldown")
	#portal_cooldown.start()
	shots = gv.shot_scenes
	gv.velocity += 2*gv.velocity
	for i in range(shots.size()):
		shots_index.push_back(i)
	#$ParallaxBackground/ParallaxLayer.motion_mirroring = $ParallaxBackground/ParallaxLayer/Sprite.texture.get_size().rotated(sprite.global_rotation)

	sb = self.get_node("sb")
	b1 = self.get_node("block_1")
	b2 = self.get_node("block_2")
	bt = self.get_node("button")
	p = self.get_node("pendulum")
	l = self.get_node("line")
	score_label = self.get_node("score_label")
	lives_label = self.get_node("lives_label")
	bt.position = gv.bt_pos
	
	# starts when a shield is created
	shield_timer_cooldown = add_timer("timer_pause", gv.shield_cooldown_time, "_on_cooldown_timeout_complete")
	
	# starts when too many shields created in a finite period (shield_limit)
	block_shield_timer = add_timer("block_shield_timer", gv.block_shield_time, "_on_block_shield_timeout_complete")
	
	self.get_node("pendulum").connect("area_entered" , self, "hit")
	self.get_node("button").connect("area_entered", self, "button_hit")
	block_cooldown = add_timer("block_timer", gv.block_cooldown_time, "_on_block_cooldown_timeout_complete")
	block_cooldown.start()
	
	# shield bar color
	sb_color = sb.get("custom_styles/bg")
	sb_color.bg_color = Color(255, 255, 255)
	#print(sb_color)

# when portal coolown completes
func _on_portal_cooldown():
	get_tree().change_scene("main.tscn")

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
	var pos = Vector2(area.position.x + (rand_dir*20), b1.position.y + 50)
	
	var new_shot_index = gv.shot_type_indices["bonus"]
	var new_shot = shots[new_shot_index].instance()
	new_shot.position = pos
	add_child(new_shot)
	shots_created += 1
	#self.get_node(new_shot.name).connect("shield_hit", self, "_shield_hit")
	#self.get_node(new_shot.name).connect("line_hit", self, "_line_hit")
	
	
# to do when shot hits the shield, for various actions such as increasing lives,
#	bonus to score, increasing shot speed, decreasing lives
func _shield_hit(node):
	#gv.background_speed += 100
	#gv.score += 2
	#score_label.text = "Score: " + str(gv.score)
	#print(gv.score)
	pass	 
	
			
func _line_hit(type):
	#gv.score -= 1
	#score_label.text = "Score: " + str(gv.score)
	#print(gv.score)
	pass

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
	
# to do when shield is hit with a shot, for counting score
func shield_hit(node):
	# check shot is from which side and increase shot count accordingly
	"""if node.position.x < 240:
		right_shot_count = 0
		if left_shot_count <= 2: 
			gv.score += 1
			left_shot_count += 1
		else: pass
	else:
		left_shot_count = 0
		if right_shot_count <= 2: 
			gv.score += 1
			right_shot_count += 1
		else: pass
	score_label.text = "Score: "+ str(gv.score)"""
	pass
	
# set allow shields to true, part of process stop player from spamming shields
func _on_cooldown_timeout_complete():
	shield_load -= shield_load_rate
	if shield_load > 0:
		shield_timer_cooldown.start()
		
# to allow shields to be generated once block_shield_timer is complete
func _on_block_shield_timeout_complete():
	stop_shield = false
	sb_color.bg_color = Color(255, 255, 255)
	

func _process(delta):
	if shots_created >= gv.portal_shots_limit:
		get_tree().change_scene("main.tscn")
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

	# if block_1 too far from center stop further movement
	if b1.position.x < 50:
		move_left = false
	# if block_1 gets too close to center stop further movement
	if b1.position.x > 240 - gv.min_gap:
		move_left = true
	# if block_2 gets too close to center stop further movement
	if b2.position.x < 240 + gv.min_gap:
		move_right = true
	# if block_2 too far from center stop further movement
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
	score_label.text = "Score: " + str(gv.score)
	lives_label.text = "Lives: " + str(gv.lives)
	
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
		# if left movement allowed move left
		if move_left == true:
			b1.position.x -= gv.block_speed
		# if left movement not allowed move right
		elif move_left == false:
			b1.position.x += gv.block_speed
	if block == b2:
		# same as b1 but opposite directions
		if move_right == true:
			b2.position.x += gv.block_speed
		elif move_right == false:
			b2.position.x -= gv.block_speed

# when input is given to move block
func _input(event):
	if event.is_action_pressed("ui_left"):
		if bt.position.x > gv.bt_pos.x - 120:
			bt.position.x -= 120
		else: pass
	if event.is_action_pressed("ui_right"):
		if bt.position.x < gv.bt_pos.x + 120:
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
