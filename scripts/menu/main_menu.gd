extends Control

# Scene Change Template
func _on_settings_pressed() -> void:
	var SettingScene :PackedScene = load("res://scenes/menu/loading.tscn")
	get_tree().change_scene_to_packed(SettingScene)
