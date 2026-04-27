extends SistemaOnline

@export var gerenciador_partida: GerenciadorPartida

var hud : Hud

var partida_comecou : bool = false

func iniciar_online_config() -> void:
	hud = gerenciador_partida.hud
	hud.partida_comecando.connect(_partida_comecando)
	hud.pausado.connect(_pausado)
	hud.despausado.connect(_despausado)

func _partida_comecando() -> void:
	partida_comecou = true
	# se for server, enviar que comecou
	if multiplayer.is_server():
		partida_comecando.rpc_id(Networking.companion_peer_id)

@rpc("authority", "call_remote", "unreliable")
func partida_comecando() -> void:
	# se ja tiver comecado, volta o relogio
	if partida_comecou:
		hud.temporizador.set_duracao(hud.duracao_partida_segundos)

func _pausado() -> void:
	print('_pausado')

func _despausado() -> void:
	print('_despausado')
