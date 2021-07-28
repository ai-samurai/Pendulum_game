extends Node2D


var score
var health
var mode
var velocity
var pendulum_velocity = 200
var background_speed = 100
var shield_cooldown_time = 0.4 # amount of time a shield stays on main scene
var block_shield_time = 6 # timer for shield blocking after spamming
var shield_limit = 3 # number of shields that are allowed in quick succession
var block_cooldown_time = 2 # minimum time block will move once movement starts
var block_speed = 2 # speed at which blocks shoudl move 
var bt_pos = Vector2(240, 750) # button position
var bt_life = 3 # button lives
var min_gap = 50 # 1/2 of min gap between the two stop blocks
var shot_type_names = {0:"normal", 1:"bomb"} #, 2: "bonus", 3: "portal", 4: "health", 5: "critical"}
var shot_types = [0,1] #,2,3,4,5]

func _ready():
	mode = 1
	score = 0
	velocity = 4
