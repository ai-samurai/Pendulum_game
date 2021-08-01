extends Node2D

onready var bomb = load("res://Objects/Bomb.tscn")
onready var normal = load("res://Objects/normal.tscn")
onready var health = load("res://Objects/health.tscn")
onready var critical = load("res://Objects/critical.tscn")
onready var bonus = load("res://Objects/bonus.tscn")
onready var portal = load("res://Objects/portal.tscn")

var score
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
var lives = 3 # button lives
var min_gap = 50 # 1/2 of min gap between the two stop blocks
var shot_type_indices = {"normal":0, "bomb":1, "health":2, "critical":3, "bonus":4, "portal":5}
var shot_types = [] #[0,1] #,2,3,4,5]
var shot_scenes
var shot_names = []
var default_velocity = 4
var portal_cooldown_time
var portal_shots_limit

func _ready():
	shot_scenes = [normal, bomb, health, critical, bonus, portal]
	mode = 1
	score = 0
	velocity = default_velocity
	portal_cooldown_time = 10
	portal_shots_limit = 21
