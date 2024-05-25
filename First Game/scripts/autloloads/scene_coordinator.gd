extends Node

# HACK: Autoloading classes and class_name actually conflict each other (if a class happens to have both and if they are the same). A class you set up for auto-load, you cant set a class_name in its script, because then the parser/compiler/editor wouldnt know if you want to access the Singleton in the autoload or the Script referenced with the class_name
# SRC: https://github.com/baconandgames/scene-manager-plus-v1.1

# internal signals
signal _content_finished_loading(key:String, content: Node)
signal _content_failed(key:String, reason: String)

# loading scene should know the key for the content
signal progress_value(key: String, value: float)

# loading scene should know the key for the content
signal done(key: String)

## cache for loaded scenes
var _internal_cache: Dictionary = {}

# key(String) - content(SceneCoordinatorData)
var _internal_data: Dictionary = {}

func _ready()-> void:
	_content_finished_loading.connect(_on_content_finished_loading)
	_content_failed.connect(_on_content_failed)

## Use the internal cache to load a scene.
func get_or_set(scene_path: String)-> PackedScene:
	if _internal_cache.has(scene_path):
		return _internal_cache[scene_path]

	var scene = load(scene_path)

	if scene is PackedScene:
		_internal_cache[scene_path] = scene
		return scene
	else:
		return null
#

func load_scene(
	loader_path: String,
	wait_time: float,
	new_scene_path: String,
	new_scene_parent: Node)-> void:
	assert(new_scene_parent, "new_scene_parent is required")
	# the unique is new_scene_path + new_scene_parent
	var key: String = "%s_%s_%s" % [new_scene_path, new_scene_parent.get_instance_id()]

	if _internal_data.has(key):
		printerr('swap_scenes: Already loading this content')
		return

	var timer: Timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(func(): _monitor_load_status(key))

	var item := SceneCoordinatorData.create_for_load(
		loader_path,
		wait_time,
		new_scene_path,
		new_scene_parent,
		timer
	)

	_internal_data[key] = item

	_execute(key)

func swap_scenes(
	loader_path: String,
	wait_time: float,
	new_scene_path: String,
	scene_to_swap: Node)-> void:
	assert(scene_to_swap, "scene_to_swap is required")
	# the unique is new_scene_path + scene_to_swap
	var key: String = "%s_%s_%s" % [new_scene_path, scene_to_swap.get_instance_id()]

	if _internal_data.has(key):
		printerr('swap_scenes: Already loading this content')
		return

	var timer: Timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(func(): _monitor_load_status(key))

	var item := SceneCoordinatorData.create_for_swap(
		loader_path,
		wait_time,
		new_scene_path,
		scene_to_swap,
		timer
	)

	_internal_data[key] = item

	_execute(key)

func switch_scenes(
	loader_path: String,
	wait_time: float,
	new_scene_path: String,
	scene_to_swap: Node)-> void:
	assert(scene_to_swap, "scene_to_swap is required")
	# the unique is new_scene_path + scene_to_swap
	var key: String = "%s_%s_%s" % [new_scene_path, scene_to_swap.get_instance_id()]

	if _internal_data.has(key):
		printerr('swap_scenes: Already loading this content')
		return

	var timer: Timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(func(): _monitor_load_status(key))

	var item := SceneCoordinatorData.create_for_switch(
		loader_path,
		wait_time,
		new_scene_path,
		scene_to_swap,
		timer
	)

	_internal_data[key] = item

	_execute(key)

func _execute(key: String)-> void:
	_add_loading_screen(key)
	_load_content(key)

func _add_loading_screen(key: String)-> void:
	if not _internal_data.has(key):
		return

	if _internal_data[key]._loader_path.is_empty():
		return

	var item = _internal_data[key] as SceneCoordinatorData
	var scene = get_or_set(item._loader_path)
	var instance: Node = scene.instantiate()

	# TODO: this is not good way to pass data
	if instance is SceneCoordinatorLoader:
		instance.set_key(key)

	item._loader_node = instance
	get_tree().root.call_deferred("add_child", instance)

func _load_content(key: String) -> void:
	if not _internal_data.has(key):
		return

	#var type_of_item = type_string(_internal_data[key])
	var item = _internal_data[key] as SceneCoordinatorData

	ResourceLoader.load_threaded_request(item._new_scene_path)
	if not ResourceLoader.exists(item._new_scene_path):
		_content_failed.emit(key, _thread_load_status_to_string(ResourceLoader.THREAD_LOAD_INVALID_RESOURCE))
		return

	item._new_scene_parent.add_child(item._timer)
	item._timer.start()

func _monitor_load_status(key: String)-> void:
	if not _internal_data.has(key):
		_content_failed.emit(key, "Missing record in dictionary")
		return

	var item = _internal_data[key] as SceneCoordinatorData

	var load_progress = []
	var load_status = ResourceLoader.load_threaded_get_status(item._new_scene_path, load_progress)

	# loading timer should be stopped in any case except THREAD_LOAD_IN_PROGRESS
	# as it will continue to call _monitor_load_status and result will be unpredictable
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			item._timer.stop()
			_content_failed.emit(key, _thread_load_status_to_string(ResourceLoader.THREAD_LOAD_INVALID_RESOURCE))
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_value.emit(key, load_progress[0] * 100) # 0.1
			return
		ResourceLoader.THREAD_LOAD_FAILED:
			item._timer.stop()
			_content_failed.emit(key, _thread_load_status_to_string(ResourceLoader.THREAD_LOAD_FAILED))
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			item._timer.stop()
			progress_value.emit(key, load_progress[0] * 100) # 0.1
			_content_finished_loading.emit(key, ResourceLoader.load_threaded_get(item._new_scene_path).instantiate())
			return

func _thread_load_status_to_string(value)-> String:
	match value:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			return "THREAD_LOAD_INVALID_RESOURCE"
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return "THREAD_LOAD_IN_PROGRESS"
		ResourceLoader.THREAD_LOAD_FAILED:
			return "THREAD_LOAD_FAILED"
		ResourceLoader.THREAD_LOAD_LOADED:
			return "THREAD_LOAD_LOADED"
		_:
			return "UNKNOWN"

func _clean_up(key: String)-> void:
	if not _internal_data.has(key):
		return

	var item = _internal_data[key] as SceneCoordinatorData

	if item._timer:
		item._timer.queue_free()

	if item._loader_node and not item._loader_node.is_queued_for_deletion():
		item._loader_node.queue_free()

	_internal_data.erase(key)

func  _on_content_failed(key: String, reason: String)-> void:
	printerr("Failed to load resource with key: '%s' due to '%s'" % [key, reason])
	_clean_up(key)

func _on_content_finished_loading(key:String, loaded_scene: Node2D)-> void:
	if not _internal_data.has(key):
		return

	var item = _internal_data[key] as SceneCoordinatorData

	if item._wait_time > 0.0:
		await get_tree().create_timer(item._wait_time).timeout

	item._new_scene_parent.add_child(loaded_scene)
	if item._new_scene_index != -1:
		item._new_scene_parent.move_child(loaded_scene, item._new_scene_index)

	done.emit(key)

	if item._new_scene_should_transform and loaded_scene is Node2D  and item._old_scene is Node2D:
		loaded_scene.transform = item._old_scene.transform

	if item._old_scene and not item._old_scene.is_queued_for_deletion() and item._old_scene != get_tree().root:
		item._old_scene.queue_free()

	_clean_up(key)
