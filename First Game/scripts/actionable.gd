extends Area2D
class_name Actionable

const Balloon = preload("res://scenes/balloon.tscn")

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String

func _ready()-> void:
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)

func action()-> void:
	if dialogue_resource and dialogue_start:
		var balloon: Node = Balloon.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(dialogue_resource, dialogue_start)
		pause(true)

func on_dialogue_ended(_resource: DialogueResource)-> void:
	pause(false)

func pause(should_pause: bool)-> void:
	get_tree().paused = should_pause
