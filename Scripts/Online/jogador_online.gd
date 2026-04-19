class_name JogadorOnline
extends Node

@export var jogador : Jogador
@export var jogador_anim : JogadorAnimation


func _init() -> void:
	if not NetworkingGame.is_game_online:
		queue_free()

func _ready() -> void:
	await get_tree().process_frame
	
	_config_do_online()

func _config_do_online() -> void:
	var peer_id_deste_jogador : int = NetworkingGame.peer_id_por_jogador_id[jogador.player_id]
	set_multiplayer_authority(peer_id_deste_jogador)
	
	# se nao for o jogador do player que esta online
	if jogador.player_id != NetworkingGame.jogador_player_id:
		Networking.node_turn_off(jogador)
