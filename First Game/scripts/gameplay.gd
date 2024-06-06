extends Node2D

@onready var level_holder = $LevelHolder as Node2D

func _ready():
	SceneCoordinator.swap_scenes(
		"res://scenes/loading_screen.tscn",
		0.5,
		"res://scenes/levels/level_one.tscn",
		level_holder.get_child(0))

func _physics_process(_delta)-> void:
	if Input.is_action_just_pressed("pause"):
		print('current pause ', get_tree().paused)
		get_tree().paused = !get_tree().paused

# HACK - fast way to load level_two
func _input(event)-> void:
	if event is InputEventKey:
		if event.keycode == 49 and event.pressed == false: # key 1 and released. otherwise SceneCoordinator.swap_scenes is called multiple times
			SceneCoordinator.swap_scenes(
				"res://scenes/loading_screen.tscn",
				0.5,
				"res://scenes/levels/level_one.tscn",
				level_holder.get_child(0))
		elif event.keycode == 50 and event.pressed == false:
			SceneCoordinator.swap_scenes(
				"res://scenes/loading_screen.tscn",
				0.5,
				"res://scenes/levels/level_two.tscn",
				level_holder.get_child(0))
