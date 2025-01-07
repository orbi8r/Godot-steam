extends Control

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var background: Panel = $Background
@onready var menu_buttons: GridContainer = $MenuButtons
@onready var lobby_list: Panel = $LobbyList

# Change this to Game Scene
var test_level = "res://scenes/game/temporary_ground.tscn"


func _ready() -> void:
	multiplayer_spawner.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	
	lobby_list.hide()


func spawn_level(data):
	var level = (load(data) as PackedScene).instantiate()
	return level


func hide_ui() -> void:
	# Hiding UI
	background.hide()
	menu_buttons.hide()
	lobby_list.hide()


func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName()+"'s Server"))
		Steam.setLobbyJoinable(lobby_id, true)
		
		print("Lobby ID: "+str(lobby_id))


func _on_host_pressed() -> void:
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	multiplayer_spawner.spawn(test_level)
	hide_ui()


func _on_browse_pressed() -> void:
	if !lobby_list.visible:
		lobby_list.show()
		open_lobby_list()
	else:
		lobby_list.hide()
		if lobby_list.get_child(0).get_child(0).get_child_count() > 0:
			for list in lobby_list.get_child(0).get_child(0).get_children():
				list.queue_free()


func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	hide_ui()


func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()


func _on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby,"name")
		if lobby_name == "":
			continue
		var member_count = Steam.getNumLobbyMembers(lobby)
		
		var lobby_button = Button.new()
		lobby_button.text = lobby_name +" : " +str(member_count) +" Players"
		lobby_button.add_theme_font_size_override("font_size", 40)
		lobby_button.connect("pressed",Callable(self,"join_lobby").bind(lobby))
		
		lobby_list.get_child(0).get_child(0).add_child(lobby_button)


func _on_refresh_pressed() -> void:
	if lobby_list.get_child(0).get_child(0).get_child_count() > 0:
		for list in lobby_list.get_child(0).get_child(0).get_children():
			list.queue_free()
	open_lobby_list()


# Scene Change Template
func _on_settings_pressed() -> void:
	var SettingScene :PackedScene = load("res://scenes/menu/loading.tscn")
	get_tree().change_scene_to_packed(SettingScene)
