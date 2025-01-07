extends Control

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var background: Panel = $Background
@onready var menu_buttons: GridContainer = $MenuButtons

# Change this to Game Scene
var test_level = "res://scenes/game/temporary_ground.tscn"


func _ready() -> void:
	multiplayer_spawner.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)


func spawn_level(data):
	var level = (load(data) as PackedScene).instantiate()
	return level


func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName()+"'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		
		print("Lobby ID: "+str(lobby_id))


func _on_host_pressed() -> void:
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	multiplayer_spawner.spawn(test_level)
	
	# Hiding UI
	background.hide()
	menu_buttons.hide()


# Scene Change Template
func _on_settings_pressed() -> void:
	var SettingScene :PackedScene = load("res://scenes/menu/loading.tscn")
	get_tree().change_scene_to_packed(SettingScene)
