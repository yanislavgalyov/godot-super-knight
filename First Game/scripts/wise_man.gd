extends CharacterBody2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String

@onready var actionable = $Actionable as Actionable

func _ready()-> void:
	if actionable:
		actionable.dialogue_resource = dialogue_resource
		actionable.dialogue_start = dialogue_start
