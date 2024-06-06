extends CharacterBody2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String
# HACK - https://github.com/godotengine/godot/issues/62916#issuecomment-1471750455
@export var external_states_node_paths: Array[NodePath]

@onready var external_states = external_states_node_paths.map(get_node)
@onready var actionable = $Actionable as Actionable

func _ready()-> void:
	if actionable:
		actionable.dialogue_resource = dialogue_resource
		actionable.dialogue_start = dialogue_start
		actionable.external_states = external_states
