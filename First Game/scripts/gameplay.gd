extends Node2D

@onready var level_holder = $LevelHolder as Node2D

func _ready():
	SceneCoordinator.swap_scenes(
		"res://scenes/loading_screen.tscn",
		0.0,
		"res://scenes/level_one.tscn",
		level_holder.get_child(0))
