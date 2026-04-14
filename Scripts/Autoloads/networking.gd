extends Node

signal client_connected_to_server
signal server_disconnected

#signal player_connected(peer_id, player_info)
#signal player_disconnected(peer_id)

signal display_error(error_code)

var ip_addr : String = "localhost"
var port : int = 45678

const MAX_CLIENTS := 1
const SERVER_ID := 1

var companion_peer_id : int = -1

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)

# ------------------ Lobby

func create_server() -> void:
	var network_peer := ENetMultiplayerPeer.new()
	var err := network_peer.create_server(port, MAX_CLIENTS)
	if err == OK:
		print("server criado")
	else:
		emit_signal("display_error", "server error code: %d" % err)
		return
	
	multiplayer.multiplayer_peer = network_peer
	print ("is server ", multiplayer.is_server())

func create_client() -> void:
	var network_peer := ENetMultiplayerPeer.new()
	var err := network_peer.create_client(ip_addr, port)
	if err == OK:
		print("cliente criado")
	else:
		emit_signal("display_error", "cliente error code: %d" % err)
		return
	
	multiplayer.multiplayer_peer = network_peer
	print ("is server ", multiplayer.is_server())

func close_connection() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	#
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	companion_peer_id = -1

# ------------------ Conection Signals

func _peer_connected(id : int):
	print("connected_to_server id: ", id)
	companion_peer_id = id

func _peer_disconnected(id : int):
	print("peer_disconnected id: ", id)
	companion_peer_id = -1

func _connected_to_server():
	print("connected_to_server")
	companion_peer_id = SERVER_ID
	emit_signal("client_connected_to_server")

func _connection_failed():
	print("connection_failed")
	companion_peer_id = -1
	emit_signal("display_error", "connection failed")

func _server_disconnected():
	print("server_disconnected")
	companion_peer_id = -1

# ------------------ Outras

# verifica se tem uma conexao funcionando
func is_network_connected() -> bool:
	return multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func get_local_ipv4() -> String:
	for address in IP.get_local_addresses():
		# pega enderecos IP v4
		if (address.split('.').size() == 4):
			# IP interno, normalmente na forma 192.168.*.*
			if address.contains("192.168"):
				return address
	# IP para localhost, ambos jogos rodando no mesmo PC
	return "127.0.0.1"
