class_name JogadorOnline
extends Node

var jogador : Jogador
var jogador_anim : JogadorAnimation

var jogador_peer_id : int

func _init() -> void:
	if not NetworkingGame.is_game_online:
		queue_free()
