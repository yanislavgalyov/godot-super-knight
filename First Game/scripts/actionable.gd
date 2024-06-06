extends Area2D
class_name Actionable

const Balloon: Resource = preload("res://scenes/balloon.tscn")

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String

var external_states: Array = []

func _ready()-> void:
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)

func action()-> void:
	if dialogue_resource and dialogue_start:
		# EXPERIMENTAL - different ways to show a custom dialogue balloon
		# DialogueManager.show_dialogue_balloon_scene(Balloon, dialogue_resource, dialogue_start)
		# DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)

		var balloon: Node = Balloon.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(dialogue_resource, dialogue_start, external_states)
		pause(true)

func on_dialogue_ended(_resource: DialogueResource)-> void:
	pause(false)

func pause(should_pause: bool)-> void:
	get_tree().paused = should_pause
