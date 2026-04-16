extends Node

## Peer_id -> Nomes dos outros jogadores 
var nomes_por_id : Dictionary[int, String] = {}

# -- Dados desse jogador --
var jogador_nome : String
var jogador_player_id := InputManager.PlayerId.P1

## Se o jogo esta no modo online
var is_game_online: bool = false

func _ready() -> void:
	Networking.client_connected_to_server.connect(_chamar_registrar_jogador)

## Ao cliente conectar ao servidor, pede para o servidor registrar_jogador
func _chamar_registrar_jogador() -> void:
	registrar_jogador.rpc_id(Networking.companion_peer_id, jogador_nome)

## Salva o nome do jogador para peer id de quem enviou
## 	se for o servidor, iniciar a selecao de level
@rpc("any_peer", "call_remote", "reliable")
func registrar_jogador(nome: String) -> void:
	# adiciona o nome do jogador que enviou o rpc
	var id: int = multiplayer.get_remote_sender_id()
	nomes_por_id[id] = nome
	# adiciona o proprio nome na lista
	id = multiplayer.get_unique_id()
	nomes_por_id[id] = jogador_nome
	
	# servidor envia seu nome e comeca a partida
	if multiplayer.is_server():
		registrar_jogador.rpc_id(Networking.companion_peer_id, jogador_nome)
		_chamar_iniciar_selecao_jogo()

## Se for o servidor, inicia a selecao de level (servidor e cliente)
func _chamar_iniciar_selecao_jogo() -> void:
	if not multiplayer.is_server(): return
	# chama inicar selecao nos 2
	iniciar_selecao_jogo()
	iniciar_selecao_jogo.rpc_id(Networking.companion_peer_id)

## Inicia a selecao de level (servidor e cliente)
@rpc("authority", "call_local", "reliable")
func iniciar_selecao_jogo() -> void:
	# ajusta os valores
	is_game_online = true
	jogador_player_id = InputManager.PlayerId.P1 if multiplayer.is_server() else InputManager.PlayerId.P2
	# inicia selecao de partida
	SceneManager.goto_selecao()
