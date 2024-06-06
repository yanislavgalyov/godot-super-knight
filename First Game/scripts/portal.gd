extends Node2D

var level_holder: Node2D

func _ready():
	level_holder = get_tree().root.get_node("GameManager/LevelHolder")

func _on_area_2d_body_entered(body):
	SceneCoordinator.swap_scenes(
		"res://scenes/loading_screen.tscn",
		0.5,
		"res://scenes/levels/level_two.tscn",
		level_holder.get_child(0))
