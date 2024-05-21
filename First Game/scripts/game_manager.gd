extends Node

var score = 0

@onready var score_label = $ScoreLabel

func add_point()-> void:
	score += 1
	score_label.text = "You collected " + str(score) + " coins."

func _physics_process(_delta)-> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
