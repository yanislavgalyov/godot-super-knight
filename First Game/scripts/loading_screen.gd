extends SceneCoordinatorLoader

@onready var progress_bar = %ProgressBar

func _ready()-> void:
	SceneCoordinator.progress_value.connect(_on_progress_value)

func _on_progress_value(key: String, value: float)-> void:
	if _internal_key == key:
		progress_bar.value = value
