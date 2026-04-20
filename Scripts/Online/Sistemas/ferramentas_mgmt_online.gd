extends SistemaOnline

@export var ferramentas_mgmt: FerramentaMgmt
@export var jogar_ferramenta_mgmt: JogarFerramentaMgmt

@onready var gerenciador_partida : GerenciadorPartida

func iniciar_online_config() -> void:
	gerenciador_partida = ferramentas_mgmt.gerenciador_partida
	ferramentas_mgmt.pegou_ferramenta.connect(_pegou_ferramenta)
	ferramentas_mgmt.dropou_ferramenta.connect(_dropou_ferramenta)

# Pegar Ferramenta
# -----------------------------------------------------------------------------

func _pegou_ferramenta(jogador: Jogador, ferramenta: Ferramenta) -> void:
	pegou_ferramenta.rpc_id(Networking.companion_peer_id, 
							jogador.player_id,
							ferramenta.tipo
							)

@rpc("any_peer", "call_remote", "reliable")
func pegou_ferramenta(jogador_id: InputManager.PlayerId, 
						ferramenta_tipo: Ferramenta.Ferramenta_tipo) -> void:
	var jogador : Jogador = _encontrar_jogador(jogador_id)
	var ferramenta : Ferramenta = _encontrar_ferramenta(ferramenta_tipo)
	var valido: bool = _valido_pegar_ferramenta(jogador, ferramenta)
	if valido:
		ferramentas_mgmt.jogador_pegar_ferramenta(jogador, ferramenta)
	else:
		if not multiplayer.is_server():
			#NetworkingGame.jogador_siri.drop_ferramenta()
			NetworkingGame.jogador.drop_ferramenta()

@rpc("authority", "call_remote", "reliable")
func negar_pegar_ferramenta() -> void:
	#TODO
	pass

func _valido_pegar_ferramenta(jogador_req: Jogador, ferramenta: Ferramenta) -> bool:
	print("_valido_pegar_ferramenta")
	for jog : Jogador in ferramentas_mgmt.jogadores_segurando_ferramenta.keys():
		# ferramenta que jog esta segurando
		var ferram : Ferramenta = ferramentas_mgmt.jogadores_segurando_ferramenta[jog]
		# jogador diferente do que requisitou o pegar ferramenta, esta segurando a ferramenta
		# 	outro jogador ja esta segurando a ferramenta
		if jog != jogador_req and ferram == ferramenta:
			print("jog != jogador_req")
			# se for o server
			#if multiplayer.is_server():
				#print("multiplayer.is_server")
				## entao tem a prioridade, e pode pegar a ferramenta
				#return true
			## se for o cliente
			#else:
				#print("not multiplayer.is_server")
				## nao tem prioridade, largue a ferramenta
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

# Funcoes Gerais
# -----------------------------------------------------------------------------

func _encontrar_jogador(jogador_id: InputManager.PlayerId) -> Jogador:
	var jogadores : Array[Jogador] = gerenciador_partida.spawn_jogadores.jogadores
	# pega o jogador com o player_id == jogador_id
	for jog in jogadores:
		if jog.player_id == jogador_id:
			return jog
	return null

func _encontrar_ferramenta(ferramenta_tipo: Ferramenta.Ferramenta_tipo) -> Ferramenta:
	# pega a ferramenta dado o tipo
	for ferram : Ferramenta in ferramentas_mgmt.ferramentas_level:
		if ferram.tipo == ferramenta_tipo:
			return ferram
	return null
