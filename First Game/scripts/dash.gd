extends Node2D
class_name Dash

@export var dash_duration: float
@export var dash_cooldown: float

@onready var dash_timer = $dash_timer as Timer
@onready var dash_cd = $dash_cd as Timer

@export var DASH_SPEED: float = 500.0
var is_dashing: bool = false
var can_dash: bool = true

func _ready():
	dash_timer.wait_time = dash_duration
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	
	dash_cd.wait_time = dash_cooldown
	dash_cd.timeout.connect(_on_dash_cd_timeout)

func start_dashing()-> void:
	if can_dash:
		is_dashing = true
		can_dash = false
		dash_timer.start()
		dash_cd.start()
	
func get_speed(speed: float)-> float:
	if is_dashing:
		return DASH_SPEED
	return speed

func _on_dash_timer_timeout():
	is_dashing = false

func _on_dash_cd_timeout():
	can_dash = true
