extends Node

var nome_jogador : String
var nomes_por_id : Dictionary[int, String] = {}

func _ready() -> void:
	Networking.client_connected_to_server.connect(_chamar_registrar_jogador)

func _client_conectado() -> void:
	print("_client_conectado")
	
	print("id: ", multiplayer.get_unique_id())
	#set_multiplayer_authority()
	#if not is_multiplayer_authority(): return
	#print("_client_conectado is_multiplayer_authority")
	
	iniciar_selecao_jogo()
	iniciar_selecao_jogo.rpc_id(Networking.companion_peer_id)

func _chamar_registrar_jogador() -> void:
	registrar_jogador.rpc_id(Networking.companion_peer_id, nome_jogador)

@rpc("any_peer", "call_remote", "reliable")
func registrar_jogador(nome: String) -> void:
	# adiciona o nome do jogador que enviou o rpc
	var id: int = multiplayer.get_remote_sender_id()
	nomes_por_id[id] = nome
	# adiciona o proprio nome na lista
	id = multiplayer.get_unique_id()
	nomes_por_id[id] = nome_jogador
	
	# servidor envia seu nome e comeca a partida
	if multiplayer.is_server():
		registrar_jogador.rpc_id(Networking.companion_peer_id, nome_jogador)
		_chamar_iniciar_selecao_jogo()

func _chamar_iniciar_selecao_jogo() -> void:
	if not multiplayer.is_server(): return
	# chama inicar selecao nos 2
	iniciar_selecao_jogo()
	iniciar_selecao_jogo.rpc_id(Networking.companion_peer_id)

@rpc("authority", "call_local", "reliable")
func iniciar_selecao_jogo() -> void:
	if multiplayer.is_server():
		print("iniciar_selecao_jogo server")
	else:
		print("iniciar_selecao_jogo client")
	SceneManager.goto_selecao()
