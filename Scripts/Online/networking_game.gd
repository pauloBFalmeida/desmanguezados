extends Node

## Peer_id -> Nomes dos outros jogadores 
var nomes_por_id : Dictionary[int, String] = {}

# -- Dados desse jogador --
var jogador_nome : String
var jogador_player_id := InputManager.PlayerId.P1

var peer_id_por_jogador_id : Dictionary[InputManager.PlayerId, int] = {}

## Se o jogo esta no modo online
var is_game_online: bool = false

func _ready() -> void:
	Networking.client_connected_to_server.connect(_chamar_registrar_jogador)
	Networking.server_disconnected.connect(_server_disconnected)
	Networking.client_disconnected.connect(_client_disconnected)

func desligar_conexao() -> void:
	# se estava estava jogando online
	if is_game_online:
		# limpa os comandos do jogados, pois podem ter sido alterados
		InputManager.reset()
	
	Networking.close_connection()
	is_game_online = false

func disconnect_signal(node: Node, signal_name: String) -> void:
	var connections = node.get_signal_connection_list(signal_name)
	for connection in connections:
		node.disconnect(signal_name, connection["callable"])

# ------------------------------------------------------------------------------
# Conexao inicial entre jogadores
# ------------------------------------------------------------------------------

## Ao cliente conectar ao servidor, pede para o servidor registrar_jogador
func _chamar_registrar_jogador() -> void:
	registrar_jogador.rpc_id(Networking.companion_peer_id, jogador_nome)

## Salva o nome do jogador para peer id de quem enviou
## 	se for o servidor, iniciar a selecao de level
@rpc("any_peer", "call_remote", "reliable")
func registrar_jogador(nome: String) -> void:
	# adiciona o nome do jogador que enviou o rpc
	var id: int = multiplayer.get_remote_sender_id()
	# atualiza os dados do jogador
	_atualizar_dados_jogador(nome, id)
	
	# servidor envia seu nome e comeca a partida
	if multiplayer.is_server():
		registrar_jogador.rpc_id(Networking.companion_peer_id, jogador_nome)
		_chamar_iniciar_selecao_jogo()

func _atualizar_dados_jogador(nome: String, id: int) -> void:
	nomes_por_id[id] = nome
	# adiciona o proprio nome na lista
	id = multiplayer.get_unique_id()
	nomes_por_id[id] = jogador_nome

# ------------------------------------------------------------------------------
# Selecao de Level
# ------------------------------------------------------------------------------
var helper_selecao_level : OnlineHelperSelecaoLevel

## Se for o servidor, inicia a selecao de level (servidor e cliente)
func _chamar_iniciar_selecao_jogo() -> void:
	if not multiplayer.is_server(): return
	# chama inicar selecao nos 2
	iniciar_selecao_jogo()
	iniciar_selecao_jogo.rpc_id(Networking.companion_peer_id)

## Inicia a selecao de level (servidor e cliente)
@rpc("authority", "call_local", "reliable")
func iniciar_selecao_jogo() -> void:
	_atualizar_dados_jogo()
	# inicia selecao de partida
	SceneManager.goto_selecao()

func _atualizar_dados_jogo() -> void:
	# marca que o jogo é online
	is_game_online = true
	
	# server P1, client P2
	jogador_player_id = InputManager.PlayerId.P1 if multiplayer.is_server() else InputManager.PlayerId.P2
	# cria o dict jogador_id -> peer_id 
	peer_id_por_jogador_id = {
		jogador_player_id: multiplayer.get_unique_id(),
		InputManager.get_other_player_id(NetworkingGame.jogador_player_id): Networking.companion_peer_id
	}

## Jogador vota no level que quer jogar
@rpc("any_peer", "call_local", "reliable")
func votar_level(level_id: int, player_id: InputManager.PlayerId) -> void:
	helper_selecao_level.player_votou_level(level_id, player_id)

# ------------------------------------------------------------------------------
# Partida
# ------------------------------------------------------------------------------

## Inicia a partida do level
func iniciar_partida(level_id: LevelManager.Level_id) -> void:
	if not multiplayer.is_server(): return
	# chama nos 2
	peer_iniciar_partida(level_id)
	peer_iniciar_partida.rpc_id(Networking.companion_peer_id, level_id)

## Inicia a partida do level para o peer
@rpc("authority", "call_local", "reliable")
func peer_iniciar_partida(level_id: LevelManager.Level_id) -> void:
	SceneManager.goto_level(level_id)

# ------------------------------------------------------------------------------
# Partida
# ------------------------------------------------------------------------------
var POP_UP_CONECTION_FAILED_REF = "uid://swjd1ii57ao4"

func _create_show_popup_conection_failed(txt: String) -> void:
	# faz o load
	var pop_up_conection_failed : PopupConectionFailed
	pop_up_conection_failed = load(POP_UP_CONECTION_FAILED_REF).instantiate()
	# atualiza o texto
	txt = txt + "\nModo Online encerrado\nVoltando para o Menu"
	pop_up_conection_failed.set_texto(txt)
	# mostra o pop up
	get_tree().current_scene.add_child(pop_up_conection_failed)
	pop_up_conection_failed.popup_centered()
	
func _server_disconnected() -> void:
	_create_show_popup_conection_failed("Host desconectado")

func _client_disconnected() -> void:
	_create_show_popup_conection_failed("Client desconectado")
	
