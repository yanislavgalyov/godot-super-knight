extends Object
class_name SceneCoordinatorData

# TODO: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

var _loader_path: String
var _wait_time: float = 0
var _new_scene_path: String
var _old_scene: Node
var _timer: Timer

#var _flag_transform: bool = false
#var _flag_unload: bool = false

var _loader_node: Node
var _new_scene_parent: Node
var _new_scene_index: int = -1
var _new_scene_should_transform: bool = false

static func create_for_swap(
	loader_path: String,
	wait_time: float,
	new_scene_path: String,
	old_scene: Node,
	timer: Timer
)-> SceneCoordinatorData:
	var data = SceneCoordinatorData.new()

	data._loader_path = loader_path
	data._wait_time = wait_time
	data._new_scene_path = new_scene_path
	data._old_scene = old_scene
	data._timer = timer

	data._new_scene_parent = old_scene.get_parent()
	data._new_scene_index = old_scene.get_index()

	return data

static func create_for_switch(
	loader_path: String,
	wait_time: float,
	new_scene_path: String,
	old_scene: Node,
	timer: Timer
)-> SceneCoordinatorData:
	var data = SceneCoordinatorData.new()

	data._loader_path = loader_path
	data._wait_time = wait_time
	data._new_scene_path = new_scene_path
	data._old_scene = old_scene
	data._timer = timer

	data._new_scene_parent = old_scene.get_parent()
	data._new_scene_index = old_scene.get_index()
	data._new_scene_should_transform = true

	return data

static func create_for_load(
	loader_path: String,
	wait_time: float,
	new_scene_path: String,
	new_scene_parent: Node,
	timer: Timer
)-> SceneCoordinatorData:
	var data = SceneCoordinatorData.new()

	data._loader_path = loader_path
	data._wait_time = wait_time
	data._new_scene_path = new_scene_path
	data._timer = timer

	data._new_scene_parent = new_scene_parent


	return data



