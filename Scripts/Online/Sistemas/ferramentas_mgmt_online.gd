class_name FerramentaMgmtOnline
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
	_lidar_plantar_unico(jogador, ferramenta)
	
	# se for valido pega a ferramenta, se nao for lide com isso
	var valido: bool = _valido_pegar_ferramenta(jogador, ferramenta)
	if valido:
		ferramentas_mgmt.jogador_pegar_ferramenta(jogador, ferramenta)
	else:
		# jogador host do servidor fica com a ferramenta
		# envia pro client cancelar o pegar a ferramenta dele
		if multiplayer.is_server():
			cancelar_pegar_ferramenta.rpc_id(Networking.companion_peer_id, jogador_id, ferramenta_tipo)

func _valido_pegar_ferramenta(jogador_req: Jogador, ferramenta: Ferramenta) -> bool:
	for jog : Jogador in ferramentas_mgmt.jogadores_segurando_ferramenta.keys():
		# ferramenta que jog esta segurando
		var ferram : Ferramenta = ferramentas_mgmt.jogadores_segurando_ferramenta[jog]
		# jogador diferente do que requisitou o pegar ferramenta, esta segurando a ferramenta
		# 	outro jogador ja esta segurando a ferramenta
		if jog != jogador_req and ferram == ferramenta:
			return false
	# caso nao tenha retornado antes, entao tudo certo, pode pegar a ferramenta
	return true

## Cancela a operacao de pegar a ferramenta
@rpc("authority", "call_remote", "reliable")
func cancelar_pegar_ferramenta(jogador_id: InputManager.PlayerId, 
								ferramenta_tipo: Ferramenta.Ferramenta_tipo) -> void:
	# converte de volta
	var jogador : Jogador = _encontrar_jogador(jogador_id)
	var ferramenta : Ferramenta = _encontrar_ferramenta(ferramenta_tipo)
	# jogador que pegou ilegalmente larga a ferramenta (cliente)
	jogador.drop_ferramenta()
	ferramenta.hide()
	# da a ferramenta pro outro jogador (servidor)
	var outro_jogador_id := InputManager.get_other_player_id(jogador_id)
	var outro_jogador : Jogador = gerenciador_partida.jogadores_por_player_id[outro_jogador_id]
	ferramentas_mgmt.jogador_pegar_ferramenta(outro_jogador, ferramenta)

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
						global_pos_ferramenta: Vector2,
						_forcar: bool = false) -> void:
	var jogador : Jogador = _encontrar_jogador(jogador_id)
	var ferramenta : Ferramenta = _encontrar_ferramenta(ferramenta_tipo)
	ferramentas_mgmt.jogador_dropar_ferramenta(jogador, ferramenta, global_pos_ferramenta, _forcar)

# Jogar Ferramenta
# -----------------------------------------------------------------------------

const JOGAR_FERRAMENTA_PLAYER_ONLINE_REF = "uid://bsnryjjdcnpem"
var jogar_ferramenta_por_jogador_id : Dictionary[InputManager.PlayerId, JogarFerramentaPlayer] = {}

func _iniciar_jogar_ferramenta() -> void:
	jogar_ferramenta_mgmt.jogador_mirando.connect(_atualizar_mirando_pos)
	jogar_ferramenta_mgmt.jogador_jogou_ferramenta.connect(_jogador_jogou_ferramenta)
	jogar_ferramenta_mgmt.jogador_cancelou_jogar.connect(_jogador_cancelou_jogar)
	jogar_ferramenta_mgmt.ferramenta_caiu_chao.connect(_ferramenta_caiu_chao)
	
	
	_criar_jogar_ferramenta_jogador(InputManager.PlayerId.P1)
	_criar_jogar_ferramenta_jogador(InputManager.PlayerId.P2)

# --- Mirando ---

func _atualizar_mirando_pos(jogador: Jogador, global_end_pos: Vector2) -> void:
	var player_id : InputManager.PlayerId = jogador.player_id
	var jogar_ferramenta := jogar_ferramenta_por_jogador_id[player_id]
	jogar_ferramenta.atualizar_mirando_pos(global_end_pos)

## Cria um Jogar Ferram Player para cada jogador
func _criar_jogar_ferramenta_jogador(jog_id: InputManager.PlayerId) -> void:
	var jogar_ferramenta_jogador = load(JOGAR_FERRAMENTA_PLAYER_ONLINE_REF).instantiate()
	# rename
	var base_name := "JogarFerramentaPlayerOnline_"
	if jog_id == InputManager.PlayerId.P1:
		jogar_ferramenta_jogador.name = base_name + "1"
	else:
		jogar_ferramenta_jogador.name = base_name + "2"
	# adiciona em cada jogador
	_add_jogar_ferramenta_jogador(jog_id, jogar_ferramenta_jogador)

func _add_jogar_ferramenta_jogador(jog_id: InputManager.PlayerId, jogar_ferramenta: JogarFerramentaPlayer) -> void:
	# salva no dict
	jogar_ferramenta_por_jogador_id[jog_id] = jogar_ferramenta
	# adiciona no jogador
	var jog: Jogador = gerenciador_partida.jogadores_por_player_id[jog_id]
	jog.add_child(jogar_ferramenta)
	# ajusta atributos
	jogar_ferramenta.jogador = jog
	jogar_ferramenta.jogar_ferramenta_mgmt = jogar_ferramenta_mgmt
	jogar_ferramenta.ferramenta_mgmt = ferramentas_mgmt
	# ajusta autoridade para o jogador poder ter controle sobre
	jogar_ferramenta.set_multiplayer_authority(NetworkingGame.peer_id_por_jogador_id[jog_id])

# --- Jogando pela mira ---
var jogador_por_ferramentas_jogadas: Dictionary[Ferramenta, Jogador] = {}

func _jogador_jogou_ferramenta(jogador : Jogador,
								ferramenta : Ferramenta, 
								global_end_pos: Vector2) -> void:
	# marca que essa ferramenta esta sendo jogada
	jogador_por_ferramentas_jogadas[ferramenta] = jogador
	# chama o rpc
	jogador_jogou_ferramenta.rpc_id(Networking.companion_peer_id, 
									jogador.player_id,
									ferramenta.tipo,
									global_end_pos
									)

@rpc("any_peer", "call_remote", "reliable")
func jogador_jogou_ferramenta(jogador_id: InputManager.PlayerId, 
								ferramenta_tipo: Ferramenta.Ferramenta_tipo,
								global_end_pos: Vector2) -> void:
	# recupera os valores
	var jogador : Jogador = _encontrar_jogador(jogador_id)
	var ferramenta : Ferramenta = _encontrar_ferramenta(ferramenta_tipo)
	jogar_ferramenta_mgmt.jogar_ferramenta_criar_curva(jogador, ferramenta, global_end_pos)

func _jogador_cancelou_jogar(jogador: Jogador) -> void:
	var jogador_id := jogador.player_id
	var jogar_ferramenta := jogar_ferramenta_por_jogador_id[jogador_id]
	# marca que nao esta mais mirando
	jogar_ferramenta.estado_jogar = JogarFerramentaPlayer.EstadoJogarFerramenta.CANCELAR
	# faz o rpc para corrigir o bug, que apos lancar e pegar outra ferramenta nao exibe novamente a curva
	#	pois ao cancelar throw em um PC ele nao tem autoridade para mudar o estado_jogador do PC (dono do jogar_ferramenta)
	jogador_cancelou_jogar.rpc_id(Networking.companion_peer_id, jogador.player_id)

@rpc("any_peer", "call_remote", "unreliable")
func jogador_cancelou_jogar(jogador_id: InputManager.PlayerId) -> void:
	var jogar_ferramenta := jogar_ferramenta_por_jogador_id[jogador_id]
	jogar_ferramenta.estado_jogar = JogarFerramentaPlayer.EstadoJogarFerramenta.CANCELAR

func _ferramenta_caiu_chao(ferramenta: Ferramenta, global_pos_ferramenta: Vector2) -> void:
	if not jogador_por_ferramentas_jogadas.has(ferramenta): return
	# pego o jogador que jogou a ferramenta
	var jogador: Jogador = jogador_por_ferramentas_jogadas[ferramenta]
	# removo da lista de ferramentas sendo jogadas
	jogador_por_ferramentas_jogadas.erase(ferramenta)
	
	# certifica que o jogador vai dropar a ferramenta para ambos os players
	dropou_ferramenta.rpc_id(Networking.companion_peer_id, 
							jogador.player_id,
							ferramenta.tipo,
							global_pos_ferramenta,
							true
							)

# Funcoes Gerais
# -----------------------------------------------------------------------------

func _encontrar_jogador(jogador_id: InputManager.PlayerId) -> Jogador:
	return gerenciador_partida.jogadores_por_player_id[jogador_id]

func _encontrar_ferramenta(ferramenta_tipo: Ferramenta.Ferramenta_tipo) -> Ferramenta:
	# pega a ferramenta dado o tipo
	for ferram : Ferramenta in ferramentas_mgmt.ferramentas_level:
		if ferram.tipo == ferramenta_tipo:
			return ferram
	# se nao tiver na lista
	if ferramenta_tipo == Ferramenta.Ferramenta_tipo.PLANTAR_UNICO:
		return ferramentas_mgmt._fabricar_ferramenta_plantar_unico(null)
	return null

func _lidar_plantar_unico(jogador: Jogador, ferramenta: Ferramenta) -> void:
	if ferramenta.tipo == Ferramenta.Ferramenta_tipo.PLANTAR_UNICO:
		jogador.add_child(ferramenta)
