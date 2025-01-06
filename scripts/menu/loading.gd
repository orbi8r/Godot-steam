extends Control

# This is the New Scene to be Loaded
var NewScene = "res://scenes/menu/settings.tscn"

@onready var loading_percentage: Label = $"Panel/Loading Percentage"
var loading_status = 0
var loading_progress = []

func _ready() -> void:
	ResourceLoader.load_threaded_request(NewScene)


func _process(delta: float) -> void:
	loading_status = ResourceLoader.load_threaded_get_status(NewScene, loading_progress)
	loading_percentage.text = str(floor(loading_progress[0]*100)) + " %"
	if loading_status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(NewScene)) 
