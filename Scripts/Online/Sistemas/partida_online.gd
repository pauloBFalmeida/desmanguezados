extends SistemaOnline

@export var gerenciador_partida: GerenciadorPartida

var hud : Hud

var partida_comecou : bool = false

func iniciar_online_config() -> void:
	hud = gerenciador_partida.hud
	# comecar partida
	hud.partida_comecando.connect(_partida_comecando)
	# pausar despausar
	hud.pausado.connect(_pausado)
	hud.despausado.connect(_despausado)
	# menu restart
	hud.button_menu.pressed.connect(_button_menu_pressed)
	hud.button_restart.pressed.connect(_button_restart_pressed)
	# mostrar tela fim
	_ajustar_tela_fim()

# Comecar Partida
# -----------------------------------------------------------------------------
func _partida_comecando() -> void:
	partida_comecou = true
	# se for server, enviar que comecou
	if multiplayer.is_server():
		partida_comecando.rpc_id(Networking.companion_peer_id)

@rpc("authority", "call_remote", "unreliable")
func partida_comecando() -> void:
	# se ja tiver comecado, volta o relogio
	if partida_comecou:
		hud.temporizador.set_duracao(gerenciador_partida.duracao_partida_segundos)

# Pausar e Despausar
# -----------------------------------------------------------------------------
func _pausado() -> void:
	pedir_pause.rpc_id(Networking.companion_peer_id)

func _despausado() -> void:
	pedir_despause.rpc_id(Networking.companion_peer_id)

@rpc("any_peer", "call_remote", "reliable")
func pedir_pause() -> void:
	hud.pausar()

@rpc("any_peer", "call_remote", "reliable")
func pedir_despause() -> void:
	hud.despausar()

# Reiniciar e Voltar ao menu
# -----------------------------------------------------------------------------
func _button_restart_pressed() -> void:
	button_restart_pressed.rpc_id(Networking.companion_peer_id)

func _button_menu_pressed() -> void:
	button_menu_pressed.rpc_id(Networking.companion_peer_id)

@rpc("any_peer", "call_remote", "reliable")
func button_restart_pressed() -> void:
	hud._on_button_restart_pressed()

@rpc("any_peer", "call_remote", "reliable")
func button_menu_pressed() -> void:
	hud._on_button_menu_pressed()
# Mostrar tela final da partida
# -----------------------------------------------------------------------------
func _ajustar_tela_fim() -> void:
	# espera 5 seg antes de fazer as configuracoes de fim de partida
	await get_tree().create_timer(5.0, true, false, true).timeout
	
	# desconecta o sinal final_partida do cliente
	if not multiplayer.is_server():
		NetworkingGame.disconnect_signal(gerenciador_partida, "final_partida")
		return
	
	# server
	gerenciador_partida.final_partida.connect(server_final_partida)

func server_final_partida(tipo : GerenciadorPartida.TipoFim, tempo_partida : int = -1) -> void:
	client_final_partida.rpc_id(Networking.companion_peer_id, tipo, tempo_partida)

@rpc("authority", "call_remote", "reliable")
func client_final_partida(tipo : GerenciadorPartida.TipoFim, tempo_partida : int = -1) -> void:
	gerenciador_partida.fim_partida()
	hud.show_tela_fim(tipo, tempo_partida)
