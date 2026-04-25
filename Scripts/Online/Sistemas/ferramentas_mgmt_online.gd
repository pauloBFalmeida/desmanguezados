extends SistemaOnline

@export var ferramentas_mgmt: FerramentaMgmt
@export var jogar_ferramenta_mgmt: JogarFerramentaMgmt

@onready var gerenciador_partida : GerenciadorPartida

func iniciar_online_config() -> void:
	gerenciador_partida = ferramentas_mgmt.gerenciador_partida
	ferramentas_mgmt.pegou_ferramenta.connect(_pegou_ferramenta)
	ferramentas_mgmt.dropou_ferramenta.connect(_dropou_ferramenta)
	# --- Jogar Ferramenta ---
	_iniciar_jogar_ferramenta()
	

# Pegar Ferramenta
# -----------------------------------------------------------------------------

func _pegou_ferramenta(jogador: Jogador, ferramenta: Ferramenta) -> void:
	pegar_ferramenta.rpc_id(Networking.companion_peer_id, 
							jogador.player_id,
							ferramenta.tipo )

@rpc("any_peer", "call_remote", "reliable")
func pegar_ferramenta(jogador_id: InputManager.PlayerId, 
						ferramenta_tipo: Ferramenta.Ferramenta_tipo) -> void:
	var jogador : Jogador = _encontrar_jogador(jogador_id)
	var ferramenta : Ferramenta = _encontrar_ferramenta(ferramenta_tipo)
	var valido: bool = _valido_pegar_ferramenta(jogador, ferramenta)
	ferramentas_mgmt.jogador_pegar_ferramenta(jogador, ferramenta)
	#if valido:
		#ferramentas_mgmt.jogador_pegar_ferramenta(jogador, ferramenta)
	#else:
		## se for o client, nao tem prioridade, nao pegou a ferramenta
		#if not multiplayer.is_server():
			#NetworkingGame.jogador_siri.limpar_jogador_ferramenta()

func _valido_pegar_ferramenta(jogador_req: Jogador, ferramenta: Ferramenta) -> bool:
	print("_valido_pegar_ferramenta")
	for jog : Jogador in ferramentas_mgmt.jogadores_segurando_ferramenta.keys():
		# ferramenta que jog esta segurando
		var ferram : Ferramenta = ferramentas_mgmt.jogadores_segurando_ferramenta[jog]
		# jogador diferente do que requisitou o pegar ferramenta, esta segurando a ferramenta
		# 	outro jogador ja esta segurando a ferramenta
		if jog != jogador_req and ferram == ferramenta:
			print("jog != jogador_req")
			print(ferramentas_mgmt.jogadores_segurando_ferramenta)
			return false
	print("return true")
	# caso nao tenha retornado antes, entao tudo certo, pode pegar a ferramenta
	return true

# Largar Ferramenta
# -----------------------------------------------------------------------------

func _dropou_ferramenta(jogador: Jogador,
						ferramenta: Ferramenta, 
						global_pos_ferramenta: Vector2) -> void:
	dropou_ferramenta.rpc_id(Networking.companion_peer_id, 
							jogador.player_id,
							ferramenta.tipo,
							global_pos_ferramenta
							)

@rpc("any_peer", "call_remote", "reliable")
func dropou_ferramenta(jogador_id: InputManager.PlayerId, 
						ferramenta_tipo: Ferramenta.Ferramenta_tipo,
						global_pos_ferramenta: Vector2) -> void:
	var jogador : Jogador = _encontrar_jogador(jogador_id)
	var ferramenta : Ferramenta = _encontrar_ferramenta(ferramenta_tipo)
	ferramentas_mgmt.jogador_dropar_ferramenta(jogador, ferramenta, global_pos_ferramenta)

# Jogar Ferramenta
# -----------------------------------------------------------------------------

enum EstadoJogarFerramenta {NENHUM, MIRANDO, JOGANDO}
@export var estado_jogar_player : Dictionary[InputManager.PlayerId, EstadoJogarFerramenta] = {
	InputManager.PlayerId.P1: EstadoJogarFerramenta.NENHUM,
	InputManager.PlayerId.P2: EstadoJogarFerramenta.NENHUM,
} :
	set(_novo_estado):
		estado_jogar_player = _novo_estado
		_update_estado_jogar()

@export var posicao_mira_player : Dictionary[InputManager.PlayerId, Vector2] = {
	InputManager.PlayerId.P1: Vector2.ZERO,
	InputManager.PlayerId.P2: Vector2.ZERO,
} :
	set(_nova_posicao):
		posicao_mira_player = _nova_posicao
		_update_posicao_mira()

func _update_estado_jogar() -> void:
	for player_id in [InputManager.PlayerId.P1, InputManager.PlayerId.P2]:
		if estado_jogar_player[player_id] == EstadoJogarFerramenta.MIRANDO:
			pass

func _update_posicao_mira() -> void:
	for player_id in [InputManager.PlayerId.P1, InputManager.PlayerId.P2]:
		if estado_jogar_player[player_id] == EstadoJogarFerramenta.MIRANDO:
			var jog: Jogador = gerenciador_partida.jogadores_por_player_id[player_id]
			var glob_pos: Vector2 =  posicao_mira_player[player_id]
			jogar_ferramenta_mgmt.mostrar_mira(jog, glob_pos)

func _atualizar_mirando_pos(jogador: Jogador, global_end_pos: Vector2) -> void:
	var player_id : InputManager.PlayerId = jogador. player_id
	# atualizo a posicao da mira
	posicao_mira_player[player_id] = global_end_pos
	# marca que esta mirando
	if estado_jogar_player[player_id] != EstadoJogarFerramenta.MIRANDO:
		estado_jogar_player[player_id] = EstadoJogarFerramenta.MIRANDO


func _iniciar_jogar_ferramenta() -> void:
	jogar_ferramenta_mgmt.jogador_mirando.connect(_atualizar_mirando_pos)


# Funcoes Gerais
# -----------------------------------------------------------------------------

func _encontrar_jogador(jogador_id: InputManager.PlayerId) -> Jogador:
	return gerenciador_partida.jogadores_por_player_id[jogador_id]

func _encontrar_ferramenta(ferramenta_tipo: Ferramenta.Ferramenta_tipo) -> Ferramenta:
	# pega a ferramenta dado o tipo
	for ferram : Ferramenta in ferramentas_mgmt.ferramentas_level:
		if ferram.tipo == ferramenta_tipo:
			return ferram
	return null
