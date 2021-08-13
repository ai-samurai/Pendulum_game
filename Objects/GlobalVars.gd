extends Node2D

onready var bomb = load("res://Objects/Bomb.tscn")
onready var normal = load("res://Objects/normal.tscn")
onready var health = load("res://Objects/health.tscn")
onready var critical = load("res://Objects/critical.tscn")
onready var bonus = load("res://Objects/bonus.tscn")
onready var portal = load("res://Objects/portal.tscn")

var score
var velocity
var pendulum_velocity = 200
var background_speed = 100

var shield_cooldown_time = 0.4 # amount of time a shield stays on main scene
var block_shield_time = 6 # timer to disallow shield for some time
var shield_limit = 3 # number of shields that are allowed in quick succession

var block_cooldown_time = 2 # minimum time block will move once movement starts
var block_speed = 2 # speed at which blocks shoudl move 

var bt_pos = Vector2(240, 750) # button position
var lives = 3 # button lives

var min_gap = 50 # 1/2 of min gap between two shots
var max_gap = 150 # 1/2 of max gap between two shots
var gap = 50 # current set gap between shots
var shot_interval = 0.75 # time interval between successive shots
var shot_interval_range = [1, 0.75, 0.5]
var shot_timer # timer to signal when to change shot_interval
signal shot_interval_changed # signal to broadcast change in shot_interval


var shot_type_indices = {"normal":0, "bomb":1, "health":2, "critical":3, "bonus":4, "portal":5}
var shot_types = [] #[0,1] #,2,3,4,5]
var shot_scenes
var shot_names
var default_velocity = 6
var main_velocity
var portal_cooldown_time
var portal_shots_limit
var shot_weights = {"normal":5, "bomb":3, "health":2, "critical":1, "bonus":2, "portal":1}
var shot_weights_sum = 0 # to store sum of weightings for shot creation
var shot_accweights = []
var rng = RandomNumberGenerator.new()

func _ready():
	gv.main_velocity = default_velocity
	rng.randomize()
	shot_scenes = [normal, bomb, health, critical, bonus, portal]
	shot_names = ["normal", "bomb", "health", "critical", "bonus", "portal"]
	score = 0
	velocity = default_velocity
	portal_cooldown_time = 10
	portal_shots_limit = 21
	
	shot_timer = add_timer("shot_timer", 4, "_on_shot_timer_complete")
	shot_timer.start()
	#for weight in shot_weights.values():
	#	shots_weight_sum += weight
	#print(shots_weight_sum)
	for shot in shot_names:
		shot_weights_sum += shot_weights[shot]
		shot_accweights.push_back(shot_weights_sum)

# when shot timer is complete, change shot_interval
func _on_shot_timer_complete():
	shot_interval = shot_interval_range[randi() % shot_interval_range.size()]
	emit_signal("shot_interval_changed")
	
# function to create a timer node and set its properties
func add_timer(timer_name, time, timer_function):
	var timer = Timer.new()
	timer.set_wait_time(time)
	add_child(timer)
	timer.name = timer_name
	timer.connect("timeout", self, timer_function)
	return timer


func pick_shot():
	# roll a random number
	#var roll:int = rand_range(0,shot_weights_sum) 
	var roll:int = rng.randi_range(0, shot_weights_sum)

	
	# loop through shot_weights array to choose first shot with accweight > roll
	for accweight in shot_accweights:
		if accweight >= roll:
			return shot_scenes[shot_accweights.find(accweight, 0)]


# to create binary to feed into _on_block_cooldown_timeout_complete() in both 
# 	main and portal_scene scripts.
#	this is used to control the movement of the blocks. 
#	a lower probability of movement is assigned if blocks are closer. 
#	returning true stops the blocks
func _block_stop(b1, b2):
	rng.randomize()
	var n = rng.randi_range(1, 10)
	# if blocks are more than 300 pixels apart stop only 10% of the time
	if b2.position.x - b1.position.x > 300:
		if n < 1: return true
		else: return false
	# if blocks are less than 200 pixels apart stop 80% of the time
	elif b2.position.x - b1.position.x < 200:
		if n < 8: return true
		else: return false
	# if blocks are not closer than 200 pixels and further apart than 300 then
	#	stop only 30% of the time
	else:
		if n < 3: return true
		else: return false


