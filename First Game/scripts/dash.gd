extends Node2D
class_name Dash

@export var player_stats: PlayerStats

@onready var dash_timer = $dash_timer as Timer
@onready var dash_cd = $dash_cd as Timer

var is_dashing: bool = false
var can_dash: bool = true

func _ready()-> void:
	dash_timer.wait_time = player_stats.DASH_DURATION
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	
	dash_cd.wait_time = player_stats.DASH_COOLDOWN
	dash_cd.timeout.connect(_on_dash_cd_timeout)

func start_dashing()-> void:
	if can_dash:
		is_dashing = true
		can_dash = false
		dash_timer.start()
		dash_cd.start()
	
func get_speed()-> float:
	return player_stats.DASH_SPEED
	
func get_acceleration()-> float:
	return player_stats.DASH_ACCELERATION
	
func get_is_dashing()-> bool:
	return is_dashing

func _on_dash_timer_timeout()-> void:
	is_dashing = false

func _on_dash_cd_timeout()-> void:
	can_dash = true
