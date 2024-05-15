extends Node

func _init():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _ready():
	DebugMenu.style = DebugMenu.Style.VISIBLE_COMPACT
