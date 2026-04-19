class_name JogadorOnline
extends SistemaOnline

@export var jogador : Jogador
@export var jogador_anim : JogadorAnimation

func iniciar_online_config() -> void:
	var peer_id_deste_jogador : int = NetworkingGame.peer_id_por_jogador_id[jogador.player_id]
	set_multiplayer_authority(peer_id_deste_jogador)
	
	# se nao for o jogador do player que esta online
	if jogador.player_id != NetworkingGame.jogador_player_id:
		# desliga jogador
		Networking.node_turn_off(jogador)
		# desliga e esconde indicador de direcao
		Networking.node_turn_off(jogador.indicador_direcao)
		jogador.indicador_direcao.hide()
