extends Node2D

var indices: Array[int]
var current: int = 0

func _ready()-> void:
	randomize()
	var children = $Coins.get_children()
	indices = get_random_indices(children)

func _physics_process(_delta)-> void:
	if Input.is_action_just_pressed("test"):
		var children = $Coins.get_children()
		if not children.is_empty() and current < len(indices):
			var random_chosen = children[indices[current]]
			#SceneCoordinator.swap_scenes(
				#"",
				#0.0,
				#"res://scenes/slime.tscn",
				#random_chosen)

			SceneCoordinator.switch_scenes(
				"",
				0.0,
				"res://scenes/slime.tscn",
				random_chosen)

			#SceneCoordinator.load_scene(
				#"",
				#0.0,
				#"res://scenes/slime.tscn",
				#$Enemies)

			current = current + 1
		else:
			print('no more children')

func get_random_indices(array: Array)-> Array[int]:
	var result: Array[int] = []
	for i in range(len(array)):
		result.append(i)

	var n = len(result)
	for i in range(n-1, 0, -1):
		var j = randi() % (i + 1)
		var temp = result[i]
		result[i] = result[j]
		result[j] = temp

	return result

