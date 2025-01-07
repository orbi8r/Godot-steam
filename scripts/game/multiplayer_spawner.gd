extends MultiplayerSpawner

@export var character_body : PackedScene
var players = {}


func _ready() -> void:
	spawn_function = spawnPlayer
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)


func spawnPlayer(data):
	var new_player = character_body.instantiate()
	new_player.set_multiplayer_authority(data)
	players[data] = new_player
	return new_player


func removePlayer(data):
	players[data].queue_free()
	players.erase(data)
