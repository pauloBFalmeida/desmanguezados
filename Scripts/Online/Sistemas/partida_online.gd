extends SistemaOnline

@export var gerenciador_partida: GerenciadorPartida

var hud : Hud

func iniciar_online_config() -> void:
	hud = gerenciador_partida.hud
	hud.partida_comecando.connect(_partida_comecando)
	hud.pausado.connect(_pausado)
	hud.despausado.connect(_despausado)

func _partida_comecando() -> void:
	print('_partida_comecando')

func _pausado() -> void:
	print('_pausado')

func _despausado() -> void:
	print('_despausado')
